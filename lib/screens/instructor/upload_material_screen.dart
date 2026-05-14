import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/classroom_model.dart';
import '../../models/material_model.dart';
import '../../services/auth_service.dart';
import '../../services/classroom_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_colors.dart';

class UploadMaterialScreen extends StatefulWidget {
  final ClassroomModel classroom;

  const UploadMaterialScreen({
    super.key,
    required this.classroom,
  });

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

  // Changed from File? to PlatformFile?
  PlatformFile? _selectedFile;
  String? _selectedFileName;

  bool _isUploading = false;
  String? _errorMessage;

  /// Allowed file types:
  /// - PDF
  /// - PowerPoint (PPT/PPTX)
  /// - MP4 Video
  static const List<String> _allowedExtensions = [
    // Documents
    'pdf',
    'doc',
    'docx',

    // Presentations
    'ppt',
    'pptx',

    // Spreadsheets
    'xls',
    'xlsx',

    // Videos
    'mp4',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Opens the file picker and restricts selection to supported formats.
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true, // Required for Flutter Web
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );

    if (result != null && result.files.isNotEmpty) {
      final pickedFile = result.files.first;

      setState(() {
        _selectedFile = pickedFile;
        _selectedFileName = pickedFile.name;

        // Auto-fill the title using the filename (without extension)
        if (_titleController.text.trim().isEmpty) {
          final dotIndex = pickedFile.name.lastIndexOf('.');
          _titleController.text = dotIndex > 0
              ? pickedFile.name.substring(0, dotIndex)
              : pickedFile.name;
        }
      });
    }
  }

  /// Uploads the selected file to Supabase Storage
  /// and saves the material metadata to the database.
  Future<void> _upload() async {
    if (_selectedFile == null) {
      setState(() {
        _errorMessage = 'Please select a file first.';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final user = context.read<AuthService>().currentUser!;

      // Upload the file and get the public URL
      final fileUrl = await _storageService.uploadMaterial(
        file: _selectedFile!,
        classroomId: widget.classroom.id,
      );

      // Create material metadata
      final material = MaterialModel(
        id: _uuid.v4(),
        classroomId: widget.classroom.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        fileUrl: fileUrl,
        uploadedBy: user.uid,
        createdAt: DateTime.now(),
      );

      // Save the material to the database
      await _classroomService.addMaterial(material);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material uploaded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Upload failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  /// Builds the upload screen UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Material'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Classroom name
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.class_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.classroom.name,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // File picker area
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
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _selectedFile == null
                      ? Column(
                          children: const [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Tap to select a file',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Supports: PDF, DOC, DOCX, PPT, PPTX, XLS, XLSX, MP4',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.attach_file_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedFileName ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _isUploading ? null : _pickFile,
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Material Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a material title.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Upload button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _upload,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload),
                  label: Text(
                    _isUploading ? 'Uploading...' : 'Upload Material',
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
