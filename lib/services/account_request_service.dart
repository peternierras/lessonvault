import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/account_request_model.dart';

class AccountRequestService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Submit a new account request
  Future<void> submitRequest({
    required String fullName,
    required String email,
    required String requestedRole,
    int? yearLevel,
    String? department,
    String? notes,
  }) async {
    await _supabase.from('account_requests').insert({
      'full_name': fullName,
      'email': email,
      'requested_role': requestedRole,
      'year_level': yearLevel,
      'department': department,
      'notes': notes,
      'status': 'pending',
    });
  }

  /// Get all pending account requests (Admin only)
  Future<List<AccountRequestModel>> getPendingRequests() async {
    final response = await _supabase
        .from('account_requests')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => AccountRequestModel.fromMap(item))
        .toList();
  }

  /// Get all account requests (Admin only)
  Future<List<AccountRequestModel>> getAllRequests() async {
    final response = await _supabase
        .from('account_requests')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => AccountRequestModel.fromMap(item))
        .toList();
  }

  /// Get a single account request by ID
  Future<AccountRequestModel?> getRequestById(
    String requestId,
  ) async {
    final response = await _supabase
        .from('account_requests')
        .select()
        .eq('id', requestId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return AccountRequestModel.fromMap(response);
  }

  /// Approve a request
  Future<void> approveRequest({
    required String requestId,
    String? adminRemarks,
  }) async {
    await _supabase.from('account_requests').update({
      'status': 'approved',
      'admin_remarks': adminRemarks,
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  /// Reject a request
  Future<void> rejectRequest({
    required String requestId,
    String? adminRemarks,
  }) async {
    await _supabase.from('account_requests').update({
      'status': 'rejected',
      'admin_remarks': adminRemarks,
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  /// Mark a request as completed after the user account
  /// has been successfully created.
  Future<void> markAsCompleted(String requestId) async {
    final response = await _supabase
        .from('account_requests')
        .update({
          'status': 'completed',
          'reviewed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .select();

    // Ensure that the update actually affected a row.
    if (response.isEmpty) {
      throw Exception(
        'Failed to mark the account request as completed.',
      );
    }
  }
}