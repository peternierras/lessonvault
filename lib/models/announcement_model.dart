class AnnouncementModel {
  final String id;
  final String classroomId;
  final String title;
  final String content;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.classroomId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classroom_id': classroomId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AnnouncementModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AnnouncementModel(
      id: map['id'] ?? '',
      classroomId: map['classroom_id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}