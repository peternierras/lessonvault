import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/account_request_service.dart';

class CreateUserScreen extends StatefulWidget {
  final String? initialFullName;
  final String? initialEmail;
  final String? initialRole;
  final String? requestId;

  const CreateUserScreen({
    super.key,
    this.initialFullName,
    this.initialEmail,
    this.initialRole,
    this.requestId,
  });

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _yearLevelController = TextEditingController();
  final _departmentController = TextEditingController();

  String _selectedRole = 'student';
  bool _isCreating = false;
  String? _errorMessage;

  final List<String> _roles = [
    'admin',
    'instructor',
    'student',
  ];

  @override
  void initState() {
    super.initState();

    _fullNameController.text = widget.initialFullName ?? '';
    _emailController.text = widget.initialEmail ?? '';
    _selectedRole = widget.initialRole ?? 'student';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _yearLevelController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    // ----------------------------------------------------------
    // RULES:
    // 1. Admin accounts can be created manually.
    // 2. Student and Instructor accounts must come from an
    //    approved account request.
    // ----------------------------------------------------------
    if (_selectedRole != 'admin' && widget.requestId == null) {
      setState(() {
        _errorMessage =
            'Student and Instructor accounts can only be created from approved account requests.';
      });
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    // ----------------------------------------------------------
    // Validate the approved request before creating the account.
    // ----------------------------------------------------------
    if (_selectedRole != 'admin' && widget.requestId != null) {
      try {
        final requestService = AccountRequestService();
        final request = await requestService.getRequestById(
          widget.requestId!,
        );

        if (request == null) {
          setState(() {
            _isCreating = false;
            _errorMessage = 'Approved request could not be found.';
          });
          return;
        }

        // Request must still be approved
        if (request.status.toLowerCase() != 'approved') {
          setState(() {
            _isCreating = false;
            _errorMessage =
                'Only requests with APPROVED status can be used to create accounts.';
          });
          return;
        }

        // Full name must match
        if (request.fullName.trim() != _fullNameController.text.trim()) {
          setState(() {
            _isCreating = false;
            _errorMessage =
                'The full name does not match the approved request.';
          });
          return;
        }

        // Email must match
        if (request.email.trim().toLowerCase() !=
            _emailController.text.trim().toLowerCase()) {
          setState(() {
            _isCreating = false;
            _errorMessage =
                'The email address does not match the approved request.';
          });
          return;
        }

        // Role must match
        if (request.requestedRole.toLowerCase() !=
            _selectedRole.toLowerCase()) {
          setState(() {
            _isCreating = false;
            _errorMessage =
                'The selected role does not match the approved request.';
          });
          return;
        }

        // Student-specific fields must match
        if (_selectedRole == 'student') {
          final enteredYear = int.tryParse(
            _yearLevelController.text.trim(),
          );
          final enteredDepartment = _departmentController.text.trim();

          if (request.yearLevel != enteredYear) {
            setState(() {
              _isCreating = false;
              _errorMessage =
                  'The year level does not match the approved request.';
            });
            return;
          }

          if ((request.department ?? '').trim() != enteredDepartment) {
            setState(() {
              _isCreating = false;
              _errorMessage =
                  'The department does not match the approved request.';
            });
            return;
          }
        }
      } catch (e) {
        setState(() {
          _isCreating = false;
          _errorMessage = 'Validation failed: $e';
        });
        return;
      }
    }

    // ----------------------------------------------------------
    // Create the user account
    // ----------------------------------------------------------
    final auth = context.read<AuthService>();

    final error = await auth.createUser(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      yearLevel: _selectedRole == 'student'
          ? int.tryParse(_yearLevelController.text.trim())
          : null,
      department:
          _selectedRole == 'student' ? _departmentController.text.trim() : null,
    );

    if (!mounted) return;

    setState(() {
      _isCreating = false;
    });

    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
      return;
    }

    // ----------------------------------------------------------
    // Mark the request as completed
    // ----------------------------------------------------------
    // Mark the request as completed (do not block the success dialog if this fails)
    if (widget.requestId != null) {
      try {
        final requestService = AccountRequestService();
        await requestService.markAsCompleted(widget.requestId!);
      } catch (e) {
        debugPrint('Failed to mark request as completed: $e');
      }
    }

    // ----------------------------------------------------------
    // Prepare credentials
    // ----------------------------------------------------------
    final credentials = 'Email: ${_emailController.text.trim()}\n'
        'Temporary Password: ${_passwordController.text}';

    // Show credentials dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Account Created Successfully'),
          content: SelectableText(credentials),
          actions: [
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: credentials),
                );

                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Credentials copied to clipboard.',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy Credentials'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    //if (mounted) {
    // Navigator.pop(context);
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the full name.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an email address.';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Temporary Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Temporary Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: _roles
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(
                          role[0].toUpperCase() + role.substring(1),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),

              // Student-only fields
              if (_selectedRole == 'student') ...[
                const SizedBox(height: 16),

                // Year Level
                TextFormField(
                  controller: _yearLevelController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Year Level',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  validator: (value) {
                    if (_selectedRole == 'student') {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the year level.';
                      }

                      final year = int.tryParse(value.trim());
                      if (year == null || year < 1 || year > 6) {
                        return 'Enter a valid year level.';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Department
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    prefixIcon: Icon(Icons.apartment_outlined),
                  ),
                  validator: (value) {
                    if (_selectedRole == 'student') {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the department.';
                      }
                    }
                    return null;
                  },
                ),
              ],

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCreating ? null : _createUser,
                  icon: _isCreating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.person_add),
                  label: Text(
                    _isCreating ? 'Creating Account...' : 'Create User Account',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
