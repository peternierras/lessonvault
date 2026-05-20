import 'package:flutter/material.dart';
import '../../models/account_request_model.dart';
import '../../services/account_request_service.dart';
import 'create_user_screen.dart';

class AccountRequestsScreen extends StatefulWidget {
  const AccountRequestsScreen({super.key});

  @override
  State<AccountRequestsScreen> createState() => _AccountRequestsScreenState();
}

class _AccountRequestsScreenState extends State<AccountRequestsScreen> {
  final _service = AccountRequestService();

  List<AccountRequestModel> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      final requests = await _service.getAllRequests();

      if (mounted) {
        setState(() {
          _requests = requests;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load requests: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<AccountRequestModel> _filterByRole(String role) {
    return _requests.where((request) => request.requestedRole == role).toList();
  }

  Future<void> _approveRequest(
    AccountRequestModel request,
  ) async {
    try {
      // Mark the request as approved
      await _service.approveRequest(
        requestId: request.id,
      );

      if (!mounted) return;

      // Refresh the list
      await _loadRequests();

      // Open Create User Account screen with pre-filled data
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateUserScreen(
            initialFullName: request.fullName,
            initialEmail: request.email,
            initialRole: request.requestedRole,
            requestId: request.id,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to approve request: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectRequest(
    AccountRequestModel request,
  ) async {
    try {
      await _service.rejectRequest(
        requestId: request.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${request.fullName} has been rejected.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      await _loadRequests();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentRequests = _filterByRole('student');
    final instructorRequests = _filterByRole('instructor');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Students'),
              Tab(text: 'Instructors'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRequests,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                children: [
                  _buildRequestList(studentRequests),
                  _buildRequestList(instructorRequests),
                ],
              ),
      ),
    );
  }

  Widget _buildRequestList(
    List<AccountRequestModel> requests,
  ) {
    if (requests.isEmpty) {
      return const Center(
        child: Text(
          'No requests found.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(request.email),
                  if (request.department != null &&
                      request.department!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Department: ${request.department}',
                      ),
                    ),
                  if (request.yearLevel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Year Level: ${request.yearLevel}',
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.status.toUpperCase(),
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: request.status == 'pending'
                              ? () => _approveRequest(
                                    request,
                                  )
                              : null,
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: request.status == 'pending'
                              ? () => _rejectRequest(
                                    request,
                                  )
                              : null,
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
