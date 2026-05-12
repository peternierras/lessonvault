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

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'name': displayName,
      'email': email,
      'role': role.name,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['id'] ?? map['uid'] ?? '',
      displayName: map['name'] ?? map['displayName'] ?? '',
      email: map['email'] ?? '',
      role: _parseRole(map['role']),
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