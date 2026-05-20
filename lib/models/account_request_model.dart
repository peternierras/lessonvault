class AccountRequestModel {
  final String id;
  final String fullName;
  final String email;
  final String requestedRole;
  final int? yearLevel;
  final String? department;
  final String? notes;
  final String status;
  final String? adminRemarks;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  AccountRequestModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.requestedRole,
    this.yearLevel,
    this.department,
    this.notes,
    required this.status,
    this.adminRemarks,
    required this.createdAt,
    this.reviewedAt,
  });

  factory AccountRequestModel.fromMap(Map<String, dynamic> map) {
    return AccountRequestModel(
      id: map['id'],
      fullName: map['full_name'],
      email: map['email'],
      requestedRole: map['requested_role'],
      yearLevel: map['year_level'],
      department: map['department'],
      notes: map['notes'],
      status: map['status'],
      adminRemarks: map['admin_remarks'],
      createdAt: DateTime.parse(map['created_at']),
      reviewedAt: map['reviewed_at'] != null
          ? DateTime.parse(map['reviewed_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'email': email,
      'requested_role': requestedRole,
      'year_level': yearLevel,
      'department': department,
      'notes': notes,
      'status': status,
      'admin_remarks': adminRemarks,
      'created_at': createdAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }
}