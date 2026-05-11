import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/classroom_model.dart';

class ClassroomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generates a random 6-character alphanumeric code
  String _generateClassCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Removed confusing chars like O, 0, I, 1
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  Future<ClassroomModel> createClassroom({
    required String name,
    required String description,
    required String instructorId,
    required String instructorName,
  }) async {
    final classCode = _generateClassCode();
    
    final docRef = _db.collection('classrooms').doc();
    
    final classroom = ClassroomModel(
      id: docRef.id,
      name: name,
      description: description,
      instructorId: instructorId,
      instructorName: instructorName,
      classCode: classCode,
      createdAt: DateTime.now(),
    );

    await docRef.set(classroom.toMap());
    return classroom;
  }
}