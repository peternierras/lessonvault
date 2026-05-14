import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/classroom_model.dart';
import '../../services/classroom_service.dart';
import '../shared/materials_list_screen.dart';

class AdminClassroomsScreen extends StatelessWidget {
  const AdminClassroomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classroomService = ClassroomService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Classrooms'),
      ),
      body: StreamBuilder<List<ClassroomModel>>(
        // Reuse the existing method by querying all classrooms directly.
        stream: classroomService
            .getStudentClassrooms('__none__'), // temporary placeholder
        builder: (context, snapshot) {
          // We will instead query manually below because getStudentClassrooms
          // only returns classrooms for a specific student.
          return FutureBuilder<List<ClassroomModel>>(
            future: _loadAllClassrooms(),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (futureSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Failed to load classrooms.\n${futureSnapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final classrooms = futureSnapshot.data ?? [];

              if (classrooms.isEmpty) {
                return const Center(
                  child: Text(
                    'No classrooms have been created yet.',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

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
                            builder: (_) => MaterialsListScreen(
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
          );
        },
      ),
    );
  }

  Future<List<ClassroomModel>> _loadAllClassrooms() async {
    final rows = await Supabase.instance.client
        .from('classrooms')
        .select()
        .order('created_at', ascending: false);

    return rows
        .map<ClassroomModel>(
          (row) => ClassroomModel.fromMap(row),
        )
        .toList();
  }
}
