import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/announcement_model.dart';
import '../../models/classroom_model.dart';
import '../../models/user_model.dart';
import '../../services/announcement_service.dart';
import '../../services/auth_service.dart';

class AnnouncementsListScreen extends StatelessWidget {
  final ClassroomModel classroom;

  const AnnouncementsListScreen({
    super.key,
    required this.classroom,
  });

  @override
  Widget build(BuildContext context) {
    final service = AnnouncementService();
    final auth = context.watch<AuthService>();

    final currentUser = auth.currentUser;
    final canManageAnnouncements =
        currentUser != null &&
        (currentUser.role == UserRole.admin ||
            currentUser.role == UserRole.instructor);

    return Scaffold(
      appBar: AppBar(
        title: Text('${classroom.name} Announcements'),
      ),
      body: StreamBuilder<List<AnnouncementModel>>(
        stream: service.getAnnouncements(classroom.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load announcements.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final announcements = snapshot.data ?? [];

          if (announcements.isEmpty) {
            return const Center(
              child: Text('No announcements yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              announcement.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          // Only admins and instructors can edit/delete
                          if (canManageAnnouncements)
                            PopupMenuButton<String>(
                              onSelected:
                                  (value) async {
                                if (value ==
                                    'edit') {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditAnnouncementScreen(
                                        classroom:
                                            classroom,
                                        announcement:
                                            announcement,
                                      ),
                                    ),
                                  );
                                } else if (value ==
                                    'delete') {
                                  final confirmed =
                                      await showDialog<bool>(
                                    context:
                                        context,
                                    builder:
                                        (_) =>
                                            AlertDialog(
                                      title:
                                          const Text(
                                        'Delete Announcement',
                                      ),
                                      content:
                                          const Text(
                                        'Are you sure you want to delete this announcement?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                            context,
                                            false,
                                          ),
                                          child:
                                              const Text(
                                            'Cancel',
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                            context,
                                            true,
                                          ),
                                          child:
                                              const Text(
                                            'Delete',
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed ==
                                      true) {
                                    try {
                                      await service
                                          .deleteAnnouncement(
                                        announcement.id,
                                      );

                                      if (context
                                          .mounted) {
                                        ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text(
                                              'Announcement deleted.',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context
                                          .mounted) {
                                        ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text(
                                              'Failed to delete announcement.\n$e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                }
                              },
                              itemBuilder:
                                  (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        announcement.content,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        announcement.createdAt
                            .toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EditAnnouncementScreen extends StatefulWidget {
  final ClassroomModel classroom;
  final AnnouncementModel announcement;

  const EditAnnouncementScreen({
    super.key,
    required this.classroom,
    required this.announcement,
  });

  @override
  State<EditAnnouncementScreen> createState() =>
      _EditAnnouncementScreenState();
}

class _EditAnnouncementScreenState
    extends State<EditAnnouncementScreen> {
  late final TextEditingController
      _titleController;
  late final TextEditingController
      _contentController;

  final AnnouncementService
      _announcementService =
      AnnouncementService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.announcement.title,
    );

    _contentController = TextEditingController(
      text: widget.announcement.content,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
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
      final updated = AnnouncementModel(
        id: widget.announcement.id,
        classroomId:
            widget.announcement.classroomId,
        title: _titleController.text.trim(),
        content:
            _contentController.text.trim(),
        createdAt:
            widget.announcement.createdAt,
      );

      await _announcementService
          .updateAnnouncement(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Announcement updated.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update announcement.\n$e',
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
        title:
            const Text('Edit Announcement'),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller:
                  _titleController,
              decoration:
                  const InputDecoration(
                labelText: 'Title',
                prefixIcon:
                    Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller:
                    _contentController,
                maxLines: null,
                expands: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Announcement Content',
                  alignLabelWithHint:
                      true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width:
                  double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : _saveChanges,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}