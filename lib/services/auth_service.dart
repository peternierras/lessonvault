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

          _currentUser = UserModel.fromMap(profile);
        } catch (e) {
          // Profile not found or query failed
          _currentUser = null;
        }
      } else {
        _currentUser = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

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
}
