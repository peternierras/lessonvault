enum UserRole {
  admin,
  instructor,
  student,
}

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final UserRole role;
  final bool mustChangePassword;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    this.mustChangePassword = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'full_name': displayName,
      'email': email,
      'role': role.name,
      'must_change_password': mustChangePassword,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['id'] ?? map['uid'] ?? '',
      displayName:
          map['full_name'] ??
          map['name'] ??
          map['displayName'] ??
          '',
      email: map['email'] ?? '',
      role: _parseRole(map['role']),
      mustChangePassword:
          map['must_change_password'] ?? false,
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'instructor':
        return UserRole.instructor;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.student;
    }
  }
}