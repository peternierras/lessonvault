import 'package:flutter/material.dart';

import '../../models/classroom_model.dart';
import '../shared/materials_list_screen.dart';
import 'upload_material_screen.dart';

class ClassroomDetailScreen extends StatelessWidget {
  final ClassroomModel classroom;

  const ClassroomDetailScreen({
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
            Text(
              classroom.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (classroom.description.isNotEmpty)
              Text(
                classroom.description,
                style: const TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 16),

            Text(
              'Class Code: ${classroom.classCode}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 32),

            // Upload Material Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Material'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadMaterialScreen(
                        classroom: classroom,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // View Materials Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
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