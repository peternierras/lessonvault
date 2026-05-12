import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/classroom_model.dart';

class ClassroomService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> createClassroom(ClassroomModel classroom) async {
    try {
      await _supabase.from('classrooms').insert(classroom.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> joinClassroom({
    required String studentId,
    required String classCode,
  }) async {
    try {
      final classroom = await _supabase
          .from('classrooms')
          .select()
          .eq('class_code', classCode)
          .maybeSingle();

      if (classroom == null) {
        return 'Classroom not found.';
      }

      // Enrollment logic can be added later.
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<ClassroomModel>> getStudentClassrooms(String studentId) {
  return _supabase
      .from('classrooms')
      .stream(primaryKey: ['id'])
      .map((rows) => <ClassroomModel>[]);
}
}