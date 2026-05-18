import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/announcement_model.dart';
import '../../models/classroom_model.dart';
import '../../services/announcement_service.dart';
import '../../services/notification_service.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final ClassroomModel classroom;

  const CreateAnnouncementScreen({
    super.key,
    required this.classroom,
  });

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends State<CreateAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final AnnouncementService _announcementService =
      AnnouncementService();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveAnnouncement() async {
    // Validate input
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter both a title and content.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create announcement object
      final announcement = AnnouncementModel(
        id: const Uuid().v4(),
        classroomId: widget.classroom.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Save to Supabase
      await _announcementService.addAnnouncement(
        announcement,
      );

      // Show local notification
      await NotificationService.instance.showNotification(
        title: 'New Announcement',
        body: _titleController.text.trim(),
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Announcement posted successfully.',
          ),
        ),
      );

      // Return to previous screen
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      // Show error if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to post announcement.\n$e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 16),

            // Content field
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: 'Announcement Content',
                  alignLabelWithHint: true,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Post button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isLoading ? null : _saveAnnouncement,
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
                        'Post Announcement',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}