import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/classroom_service.dart';
import '../../utils/app_colors.dart';

class CreateClassroomScreen extends StatefulWidget {
  final String instructorId;
  final String instructorName;

  const CreateClassroomScreen({
    super.key,
    required this.instructorId,
    required this.instructorName,
  });

  @override
  State<CreateClassroomScreen> createState() => _CreateClassroomScreenState();
}

class _CreateClassroomScreenState extends State<CreateClassroomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _classroomService = ClassroomService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _createClassroom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final classroom = await _classroomService.createClassroom(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        instructorId: widget.instructorId,
        instructorName: widget.instructorName,
      );

      if (mounted) {
        // Show success with the generated class code
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _ClassCodeDialog(
            classroomName: classroom.name,
            classCode: classroom.classCode,
          ),
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to create classroom. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Classroom'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Classroom details',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'A unique class code will be automatically generated after creation.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Classroom / Course Name',
                  hintText: 'e.g. Introduction to Computer Science',
                  prefixIcon: Icon(Icons.class_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a classroom name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Brief description of this course',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createClassroom,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create Classroom'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog shown after classroom creation with the auto-generated code.
class _ClassCodeDialog extends StatelessWidget {
  final String classroomName;
  final String classCode;

  const _ClassCodeDialog({
    required this.classroomName,
    required this.classCode,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(28),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.success, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Classroom Created!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(classroomName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          const Text('Class Code',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              classCode,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 6),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: classCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code copied!')),
              );
            },
            icon: const Icon(Icons.copy_outlined, size: 16),
            label: const Text('Copy code'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share this code with students so they can join.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
