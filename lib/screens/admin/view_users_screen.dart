import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewUsersScreen extends StatelessWidget {
  const ViewUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Users'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('profiles')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false),
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
                'Failed to load users.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final users = snapshot.data ?? [];

          // Empty state
          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No users found.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // User list
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];

              final name =
                  (user['full_name'] ??
                          user['name'] ??
                          'Unnamed User')
                      .toString();

              final email =
                  (user['email'] ?? 'No email')
                      .toString();

              final role =
                  (user['role'] ?? 'Unknown')
                      .toString();

              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      role.isNotEmpty
                          ? role[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(name),
                  subtitle: Text(
                    '$email\nRole: ${role.toUpperCase()}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}