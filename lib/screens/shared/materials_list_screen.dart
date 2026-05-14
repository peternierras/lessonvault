import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/classroom_model.dart';
import '../../models/material_model.dart';
import '../../services/classroom_service.dart';
import '../../services/storage_service.dart';

class MaterialsListScreen extends StatelessWidget {
  final ClassroomModel classroom;

  const MaterialsListScreen({
    super.key,
    required this.classroom,
  });

  /// Returns an icon based on the file extension.
  IconData _getFileIcon(String url) {
    final lowerUrl = url.toLowerCase();

    if (lowerUrl.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lowerUrl.endsWith('.ppt') || lowerUrl.endsWith('.pptx')) {
      return Icons.slideshow;
    }
    if (lowerUrl.endsWith('.doc') || lowerUrl.endsWith('.docx')) {
      return Icons.description;
    }
    if (lowerUrl.endsWith('.xls') || lowerUrl.endsWith('.xlsx')) {
      return Icons.table_chart;
    }
    if (lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.avi')) {
      return Icons.video_library;
    }

    return Icons.insert_drive_file;
  }

  /// Returns a color based on the file extension.
  Color _getFileColor(String url) {
    final lowerUrl = url.toLowerCase();

    if (lowerUrl.endsWith('.pdf')) return Colors.red;
    if (lowerUrl.endsWith('.ppt') || lowerUrl.endsWith('.pptx')) {
      return Colors.deepOrange;
    }
    if (lowerUrl.endsWith('.doc') || lowerUrl.endsWith('.docx')) {
      return Colors.blue;
    }
    if (lowerUrl.endsWith('.xls') || lowerUrl.endsWith('.xlsx')) {
      return Colors.green;
    }
    if (lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.avi')) {
      return Colors.purple;
    }

    return Colors.grey;
  }

  /// Returns the file extension label shown under the icon.
  String _getFileExtension(String url) {
    final lowerUrl = url.toLowerCase();

    if (lowerUrl.endsWith('.pdf')) return 'PDF';
    if (lowerUrl.endsWith('.doc')) return 'DOC';
    if (lowerUrl.endsWith('.docx')) return 'DOCX';
    if (lowerUrl.endsWith('.ppt')) return 'PPT';
    if (lowerUrl.endsWith('.pptx')) return 'PPTX';
    if (lowerUrl.endsWith('.xls')) return 'XLS';
    if (lowerUrl.endsWith('.xlsx')) return 'XLSX';
    if (lowerUrl.endsWith('.mp4')) return 'MP4';
    if (lowerUrl.endsWith('.mov')) return 'MOV';
    if (lowerUrl.endsWith('.avi')) return 'AVI';

    return 'FILE';
  }

  /// Opens the selected file.
  Future<void> _openMaterial(
    BuildContext context,
    MaterialModel material,
  ) async {
    final uri = Uri.parse(material.fileUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the file.'),
          ),
        );
      }
    }
  }

  /// Deletes the selected material after confirmation.
  Future<void> _deleteMaterial(
    BuildContext context,
    MaterialModel material,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Delete Material'),
              content: Text(
                'Are you sure you want to delete "${material.title}"?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    final storageService = StorageService();
    final classroomService = ClassroomService();

    try {
      // Delete file from Supabase Storage
      await storageService.deleteMaterial(material.fileUrl);

      // Delete database record
      await classroomService.deleteMaterial(material.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material deleted successfully.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete material: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final classroomService = ClassroomService();

    return Scaffold(
      appBar: AppBar(
        title: Text('${classroom.name} Materials'),
      ),
      body: StreamBuilder<List<MaterialModel>>(
        stream: classroomService.getMaterials(classroom.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load materials.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final materials = snapshot.data ?? [];

          if (materials.isEmpty) {
            return const Center(
              child: Text(
                'No materials have been uploaded yet.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: materials.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final material = materials[index];
              final fileColor = _getFileColor(material.fileUrl);

              return Card(
                elevation: 2,
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: fileColor.withOpacity(0.12),
                          child: Icon(
                            _getFileIcon(material.fileUrl),
                            color: fileColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getFileExtension(material.fileUrl),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: fileColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  title: Text(material.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (material.description.isNotEmpty)
                        Text(material.description),
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded ${DateFormat.yMMMd().add_jm().format(material.createdAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  isThreeLine: material.description.isNotEmpty,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'open') {
                        _openMaterial(context, material);
                      } else if (value == 'delete') {
                        _deleteMaterial(context, material);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'open',
                        child: ListTile(
                          leading: Icon(Icons.open_in_new),
                          title: Text('Open'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          title: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _openMaterial(context, material),
                ),
              );
            },
          );
        },
      ),
    );
  }
}