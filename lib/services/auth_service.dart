import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  AuthService() {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    // Listen for login/logout events
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final user = session?.user;

      if (user != null) {
        try {
          final profile = await _supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .single();

          // Print the raw data returned from Supabase
          print('Profile data: $profile');

          // Convert the profile into UserModel
          _currentUser = UserModel.fromMap(profile);

          // Print the parsed role
          print('Loaded role: ${_currentUser?.role}');
        } catch (e) {
          // Print any error that occurs while loading the profile
          print('Error loading profile: $e');

          _currentUser = null;
        }
      } else {
        _currentUser = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Signs in using email and password.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    int? yearLevel,
    String? department,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'create-user',
        body: {
          'email': email.trim(),
          'password': password,
          'full_name': fullName.trim(),
          'role': role.toLowerCase(),
          'year_level': role.toLowerCase() == 'student' ? yearLevel : null,
          'department':
              role.toLowerCase() == 'student' ? department?.trim() : null,
        },
      );

      if (response.data == null || response.data['success'] != true) {
        return response.data?['error'] ?? 'Failed to create user.';
      }

      return null;
    } on FunctionException catch (e) {
      return e.toString();
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> changePassword({
    required String newPassword,
  }) async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        return 'No authenticated user found.';
      }

      // 1. Update the password
      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      // 2. Update the profile flag
      await _supabase.from('profiles').update({
        'must_change_password': false,
      }).eq('id', user.id);

      // 3. Reload the profile from the database
      final profile =
          await _supabase.from('profiles').select().eq('id', user.id).single();

      // Debug output
      print('Updated profile after password change: $profile');

      // 4. Update local user state
      _currentUser = UserModel.fromMap(profile);

      // Debug output
      print('Role after password change: ${_currentUser?.role}');

      // 5. Notify listeners so AuthWrapper rebuilds
      _isLoading = false;
      notifyListeners();

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Sends a password reset email to the user.
  Future<String?> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
      );

      return null; // Success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
