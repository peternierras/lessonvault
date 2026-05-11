import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/classroom_model.dart';
import '../../models/material_model.dart';
import '../../services/classroom_service.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class UploadMaterialScreen extends StatefulWidget {
  final ClassroomModel classroom;
  const UploadMaterialScreen({super.key, required this.classroom});

  @override
  State<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends State<UploadMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _classroomService = ClassroomService();
  final _storageService = StorageService();
  final _uuid = const Uuid();

  File? _selectedFile;
  String? _selectedFileName;
  bool _isUploading = false;
  double _uploadProgress = 0;
  String? _errorMessage;

  static const _allowedExtensions = ['pdf', 'pptx', 'ppt', 'mp4', 'mov'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
        // Auto-fill title with filename (without extension)
        if (_titleController.text.isEmpty) {
          final name = result.files.single.name;
          final dot = name.lastIndexOf('.');
          _titleController.text = dot >= 0 ? name.substring(0, dot) : name;
        }
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) {
      setState(() => _errorMessage = 'Please select a file to upload.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isUploading = true; _errorMessage = null; _uploadProgress = 0; });

    try {
      final user = context.read<AuthService>().currentUser!;

      final result = await _storageService.uploadMaterial(
        file: _selectedFile!,
        classroomId: widget.classroom.id,
        onProgress: (p) => setState(() => _uploadProgress = p),
      );

      final material = MaterialModel(
        id: _uuid.v4(),
        classroomId: widget.classroom.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        fileUrl: result.url,
        type: result.type,
        uploadedById: user.uid,
        uploadedByName: user.displayName,
        uploadedAt: DateTime.now(),  // Auto-stamped
        fileSizeBytes: result.sizeBytes,
        fileName: result.fileName,
      );

      await _classroomService.addMaterial(material);  // Also triggers notification

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material uploaded! Students will be notified.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Upload failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Material')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Classroom indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.class_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(widget.classroom.name,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // File picker zone
              GestureDetector(
                onTap: _isUploading ? null : _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _selectedFile != null
                        ? AppColors.primaryLight
                        : AppColors.surface,
                    border: Border.all(
                      color: _selectedFile != null
                          ? AppColors.primary
                          : AppColors.border,
                      width: _selectedFile != null ? 2 : 1,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _selectedFile == null
                      ? Column(
                          children: [
                            const Icon(Icons.cloud_upload_outlined,
                                size: 40, color: AppColors.textSecondary),
                            const SizedBox(height: 10),
                            const Text('Tap to select a file',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text(
                              'Supports: ${_allowedExtensions.map((e) => e.toUpperCase()).join(', ')}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(Icons.attach_file_outlined,
                                color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedFileName ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: _pickFile,
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Material Title',
                  prefixIcon: Icon(Icons.title_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
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

              if (_isUploading) ...[
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uploading… ${(_uploadProgress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _upload,
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text('Upload & Notify Students'),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Students will receive an automatic notification on upload.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
