import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/classroom_model.dart';
import '../shared/materials_list_screen.dart';

class AdminClassroomsScreen extends StatelessWidget {
  const AdminClassroomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Classrooms'),
      ),
      body: FutureBuilder<List<ClassroomModel>>(
        future: _loadAllClassrooms(),
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
                'No classrooms have been created yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Group classrooms by year level
          final groupedClassrooms = <int, List<ClassroomModel>>{
            1: [],
            2: [],
            3: [],
            4: [],
          };

          for (final classroom in classrooms) {
            if (groupedClassrooms.containsKey(classroom.yearLevel)) {
              groupedClassrooms[classroom.yearLevel]!.add(classroom);
            } else {
              groupedClassrooms[1]!.add(classroom);
            }
          }

          // Build categorized list
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final yearLevel in [1, 2, 3, 4])
                if (groupedClassrooms[yearLevel]!.isNotEmpty) ...[
                  _YearSection(
                    title: _getYearSectionTitle(yearLevel),
                    classrooms: groupedClassrooms[yearLevel]!,
                  ),
                  const SizedBox(height: 24),
                ],
            ],
          );
        },
      ),
    );
  }

  Future<List<ClassroomModel>> _loadAllClassrooms() async {
    final rows = await Supabase.instance.client
        .from('classrooms')
        .select()
        .order('year_level', ascending: true)
        .order('created_at', ascending: false);

    return rows
        .map<ClassroomModel>(
          (row) => ClassroomModel.fromMap(row),
        )
        .toList();
  }

  static String _getYearSectionTitle(int yearLevel) {
    switch (yearLevel) {
      case 1:
        return '1st Year Classrooms';
      case 2:
        return '2nd Year Classrooms';
      case 3:
        return '3rd Year Classrooms';
      case 4:
        return '4th Year Classrooms';
      default:
        return 'Other Classrooms';
    }
  }
}

class _YearSection extends StatelessWidget {
  final String title;
  final List<ClassroomModel> classrooms;

  const _YearSection({
    required this.title,
    required this.classrooms,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(
            left: 4,
            bottom: 12,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Classrooms under this year level
        ...classrooms.map(
          (classroom) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  child: Icon(
                    Icons.class_,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
            ),
          ),
        ),
      ],
    );
  }
}