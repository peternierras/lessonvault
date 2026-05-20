import 'package:flutter/material.dart';
import '../../services/account_request_service.dart';

class AccountRequestScreen extends StatefulWidget {
  const AccountRequestScreen({super.key});

  @override
  State<AccountRequestScreen> createState() => _AccountRequestScreenState();
}

class _AccountRequestScreenState extends State<AccountRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AccountRequestService();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _yearLevelController = TextEditingController();
  final _departmentController = TextEditingController();
  final _notesController = TextEditingController();

  String _requestedRole = 'student';
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _yearLevelController.dispose();
    _departmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _service.submitRequest(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        requestedRole: _requestedRole,
        yearLevel: _requestedRole == 'student'
            ? int.tryParse(_yearLevelController.text.trim())
            : null,
        department: _requestedRole == 'student'
            ? (_departmentController.text.trim().isEmpty
                ? null
                : _departmentController.text.trim())
            : null,
        notes: null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account request submitted successfully. Please wait for admin approval.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request an Account'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Fill out the form below to request an account.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: _inputDecoration('Full Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Full name is required'
                        : null,
              ),
              const SizedBox(height: 16),

              // Email Address
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Email Address'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Requested Role
              DropdownButtonFormField<String>(
                value: _requestedRole,
                decoration: _inputDecoration('Requested Role'),
                items: const [
                  DropdownMenuItem(
                    value: 'student',
                    child: Text('Student'),
                  ),
                  DropdownMenuItem(
                    value: 'instructor',
                    child: Text('Instructor'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _requestedRole = value;

                      // Clear student-only fields when switching to instructor
                      if (_requestedRole != 'student') {
                        _yearLevelController.clear();
                        _departmentController.clear();
                      }
                    });
                  }
                },
              ),

              // Show only for Student
              if (_requestedRole == 'student') ...[
                const SizedBox(height: 16),

                // Year Level
                TextFormField(
                  controller: _yearLevelController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Year Level'),
                  validator: (value) {
                    if (_requestedRole == 'student') {
                      if (value == null || value.trim().isEmpty) {
                        return 'Year level is required';
                      }

                      final year = int.tryParse(value.trim());
                      if (year == null || year < 1 || year > 6) {
                        return 'Enter a valid year level';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Department
                TextFormField(
                  controller: _departmentController,
                  decoration: _inputDecoration('Department'),
                  validator: (value) {
                    if (_requestedRole == 'student') {
                      if (value == null || value.trim().isEmpty) {
                        return 'Department is required';
                      }
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}