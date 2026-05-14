import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/classroom_service.dart';
import '../../models/classroom_model.dart';
import '../../utils/app_colors.dart';
import 'student_classroom_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final _classroomService = ClassroomService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('LessonVault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _MyClassroomsTab(
            classroomService: _classroomService,
            studentId: user.uid,
          ),
          const _AnnouncementsTab(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showJoinDialog(context, user.uid),
              backgroundColor: AppColors.studentColor,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text('Join Classroom',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.class_outlined), label: 'My Classes'),
          NavigationDestination(
              icon: Icon(Icons.campaign_outlined), label: 'Announcements'),
        ],
      ),
    );
  }

  Future<void> _showJoinDialog(BuildContext context, String studentId) async {
    final codeController = TextEditingController();
    final service = _classroomService;

    await showDialog(
      context: context,
      builder: (dialogCtx) => _JoinClassroomDialog(
        codeController: codeController,
        onJoin: (code) async {
          final error = await service.joinClassroom(
            classCode: code,
            studentId: studentId,
          );
          if (dialogCtx.mounted) {
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(error), backgroundColor: AppColors.error),
              );
            } else {
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Joined classroom successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class _MyClassroomsTab extends StatelessWidget {
  final ClassroomService classroomService;
  final String studentId;

  const _MyClassroomsTab({
    required this.classroomService,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClassroomModel>>(
      stream: classroomService.getStudentClassrooms(studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final classrooms = snapshot.data ?? [];

        if (classrooms.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_outlined,
                      size: 64, color: AppColors.border),
                  const SizedBox(height: 16),
                  const Text('No classrooms yet',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap "Join Classroom" and enter the class code your instructor shared with you.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Join a Classroom'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: classrooms.length,
          itemBuilder: (context, i) =>
              _StudentClassroomCard(classroom: classrooms[i]),
        );
      },
    );
  }
}

class _StudentClassroomCard extends StatelessWidget {
  final ClassroomModel classroom;

  const _StudentClassroomCard({
    required this.classroom,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentClassroomScreen(
              classroom: classroom,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.studentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.class_outlined,
                  color: AppColors.studentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classroom.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      classroom.instructorName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementsTab extends StatelessWidget {
  const _AnnouncementsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Announcements'));
  }
}

class _JoinClassroomDialog extends StatefulWidget {
  final TextEditingController codeController;
  final Future<void> Function(String code) onJoin;

  const _JoinClassroomDialog({
    required this.codeController,
    required this.onJoin,
  });

  @override
  State<_JoinClassroomDialog> createState() => _JoinClassroomDialogState();
}

class _JoinClassroomDialogState extends State<_JoinClassroomDialog> {
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Join Classroom'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter the class code shared by your instructor.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.codeController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 6,
              color: AppColors.primary,
            ),
            decoration: InputDecoration(
              hintText: 'ABC123',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
                letterSpacing: 4,
                fontSize: 20,
              ),
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isJoining
              ? null
              : () async {
                  final code = widget.codeController.text.trim();
                  if (code.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Code must be 6 characters')),
                    );
                    return;
                  }
                  setState(() => _isJoining = true);
                  await widget.onJoin(code);
                  if (mounted) setState(() => _isJoining = false);
                },
          child: _isJoining
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Join'),
        ),
      ],
    );
  }
}
