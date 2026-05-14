import 'package:flutter/material.dart';

import '../../models/classroom_model.dart';
import '../shared/materials_list_screen.dart';

class StudentClassroomScreen extends StatelessWidget {
  final ClassroomModel classroom;

  const StudentClassroomScreen({
    super.key,
    required this.classroom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classroom.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Classroom Name
            Text(
              classroom.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            if (classroom.description.isNotEmpty)
              Text(
                classroom.description,
                style: const TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 16),

            // Class Code
            Text(
              'Class Code: ${classroom.classCode}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 32),

            // View Materials Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.folder_open),
                label: const Text('View Materials'),
                onPressed: () {
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
          ],
        ),
      ),
    );
  }
}