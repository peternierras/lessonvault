class MaterialModel {
  final String id;
  final String classroomId;
  final String title;
  final String description;
  final String fileUrl;
  final String uploadedBy;
  final DateTime createdAt;

  MaterialModel({
    required this.id,
    required this.classroomId,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.uploadedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classroom_id': classroomId,
      'title': title,
      'description': description,
      'file_url': fileUrl,
      'uploaded_by': uploadedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] as String,
      classroomId: map['classroom_id'] as String,
      title: map['title'] as String,
      description: (map['description'] ?? '') as String,
      fileUrl: map['file_url'] as String,
      uploadedBy: map['uploaded_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}