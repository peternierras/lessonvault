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
      'id': id,
      'name': name,
      'description': description,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'classCode': classCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}