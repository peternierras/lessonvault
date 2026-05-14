class ClassroomModel {
  final String id;
  final String name;
  final String description;
  final String instructorId;
  final String instructorName;
  final String classCode;
  final DateTime createdAt;

  ClassroomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    required this.classCode,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id.isEmpty ? null : id,
      'name': name,
      'description': description,
      'instructor_id':
          instructorId.isEmpty ? null : instructorId,
      'instructor_name': instructorName,
      'class_code': classCode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ClassroomModel.fromMap(Map<String, dynamic> map) {
    return ClassroomModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      instructorId: map['instructor_id'] ?? '',
      instructorName: map['instructor_name'] ?? '',
      classCode: map['class_code'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}