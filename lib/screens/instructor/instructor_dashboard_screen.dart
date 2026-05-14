import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/classroom_model.dart';
import '../../services/auth_service.dart';
import 'classroom_detail_screen.dart';

class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;

    // Safety check in case no instructor is signed in
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No instructor is currently signed in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ClassroomModel>>(
        // Shows only classrooms assigned to the logged-in instructor
        stream: Supabase.instance.client
            .from('classrooms')
            .stream(primaryKey: ['id'])
            .eq('instructor_id', user.uid)
            .map(
              (rows) => rows
                  .map((row) => ClassroomModel.fromMap(row))
                  .toList(),
            ),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load classrooms.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final classrooms = snapshot.data ?? [];

          // Empty state
          if (classrooms.isEmpty) {
            return const Center(
              child: Text(
                'No classrooms assigned to you yet.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Classroom list
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: classrooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final classroom = classrooms[index];

              return Card(
                elevation: 2,
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.class_),
                  ),
                  title: Text(classroom.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (classroom.description.isNotEmpty)
                        Text(classroom.description),
                      const SizedBox(height: 4),
                      Text(
                        'Class Code: ${classroom.classCode}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClassroomDetailScreen(
                          classroom: classroom,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}