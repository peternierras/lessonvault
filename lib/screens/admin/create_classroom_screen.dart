import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/classroom_service.dart';
import '../../utils/app_colors.dart';

class CreateClassroomScreen extends StatefulWidget {
  const CreateClassroomScreen({super.key});

  @override
  State<CreateClassroomScreen> createState() =>
      _CreateClassroomScreenState();
}

class _CreateClassroomScreenState
    extends State<CreateClassroomScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _instructorIdController = TextEditingController();
  final _instructorNameController =
      TextEditingController();

  final ClassroomService _classroomService =
      ClassroomService();

  // Default year level = 1st Year
  int _selectedYearLevel = 1;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _instructorIdController.dispose();
    _instructorNameController.dispose();
    super.dispose();
  }

  Future<void> _createClassroom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final classroom =
          await _classroomService.createClassroom(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        instructorId:
            _instructorIdController.text.trim(),
        instructorName:
            _instructorNameController.text.trim(),
        yearLevel: _selectedYearLevel,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ClassCodeDialog(
          classroomName: classroom.name,
          classCode: classroom.classCode,
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Failed to create classroom. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getYearLabel(int year) {
    switch (year) {
      case 1:
        return '1st Year';
      case 2:
        return '2nd Year';
      case 3:
        return '3rd Year';
      case 4:
        return '4th Year';
      default:
        return '$year Year';
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Classroom Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'A unique class code will be automatically generated after creation.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Classroom Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText:
                      'Classroom / Course Name',
                  hintText:
                      'e.g. Introduction to Computer Science',
                  prefixIcon:
                      Icon(Icons.class_outlined),
                ),
                textCapitalization:
                    TextCapitalization.words,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter a classroom name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Year Level Dropdown
              DropdownButtonFormField<int>(
                value: _selectedYearLevel,
                decoration: const InputDecoration(
                  labelText: 'Year Level',
                  prefixIcon:
                      Icon(Icons.school_outlined),
                ),
                items: [1, 2, 3, 4]
                    .map(
                      (year) =>
                          DropdownMenuItem<int>(
                        value: year,
                        child: Text(
                          _getYearLabel(year),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedYearLevel = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText:
                      'Description (optional)',
                  hintText:
                      'Brief description of this course',
                  prefixIcon: Icon(
                    Icons.description_outlined,
                  ),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              // Instructor UID
              TextFormField(
                controller:
                    _instructorIdController,
                decoration: const InputDecoration(
                  labelText:
                      'Instructor ID (UID)',
                  hintText:
                      'Paste the instructor UID from Supabase Auth',
                  prefixIcon:
                      Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Enter the instructor UID';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Instructor Name
              TextFormField(
                controller:
                    _instructorNameController,
                decoration: const InputDecoration(
                  labelText:
                      'Instructor Name',
                  prefixIcon:
                      Icon(Icons.person_outline),
                ),
                textCapitalization:
                    TextCapitalization.words,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Enter the instructor name';
                  }
                  return null;
                },
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error
                        .withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _createClassroom,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Classroom',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
      contentPadding:
          const EdgeInsets.all(28),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.success
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Classroom Created!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            classroomName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Class Code',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color:
                  AppColors.primaryLight,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Text(
              classCode,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: classCode,
                ),
              );

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content:
                      Text('Code copied!'),
                ),
              );
            },
            icon: const Icon(
              Icons.copy_outlined,
              size: 16,
            ),
            label: const Text(
              'Copy Code',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share this code with students so they can join.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}