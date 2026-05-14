import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import 'admin_classrooms_screen.dart';
import 'create_classroom_screen.dart';
import 'view_users_screen.dart';
import 'create_user_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            // Create User Account
            _buildMenuButton(
              context,
              title: 'Create User Account',
              icon: Icons.person_add,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateUserScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Create Classroom
            _buildMenuButton(
              context,
              title: 'Create Classroom',
              icon: Icons.class_,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateClassroomScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // View Classrooms
            _buildMenuButton(
              context,
              title: 'View Classrooms',
              icon: Icons.folder_open,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminClassroomsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // View Users
            _buildMenuButton(
              context,
              title: 'View Users',
              icon: Icons.people,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ViewUsersScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(title),
        onPressed: onTap,
      ),
    );
  }
}
