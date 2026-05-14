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

  /// Creates a new user account and inserts a matching row
  /// into the profiles table.
  ///
  /// NOTE:
  /// This method requires that your project is configured to allow
  /// creating users from the client. In production, this is typically
  /// done through a secure server or Edge Function using the service role key.
  Future<String?> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      // Create the authentication account
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      final authUser = response.user;

      if (authUser == null) {
        return 'Failed to create user account.';
      }

      // Insert the corresponding profile record
      await _supabase.from('profiles').upsert({
        'id': authUser.id,
        'email': email.trim(),
        'name': fullName.trim(),
        'role': role.toLowerCase(),
      });

      return null; // Success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
