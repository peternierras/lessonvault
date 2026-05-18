import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/classroom_model.dart';
import '../models/material_model.dart';

class ClassroomService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Creates a classroom and automatically generates a unique class code.
  /// Returns the created ClassroomModel.
  Future<ClassroomModel> createClassroom({
    required String name,
    required String description,
    required String instructorId,
    required String instructorName,
    required int yearLevel,
  }) async {
    // Generate a random 6-character code
    final classCode = _generateClassCode();

    // Data to insert into Supabase
    final data = {
      'name': name,
      'description': description,
      'instructor_id':
          instructorId.trim().isEmpty ? null : instructorId,
      'instructor_name': instructorName,
      'class_code': classCode,
      'year_level': yearLevel,
    };

    // Insert and return the newly created row
    final response = await _supabase
        .from('classrooms')
        .insert(data)
        .select()
        .single();

    return ClassroomModel.fromMap(response);
  }

  /// Generates a random classroom code such as PA22YA.
  String _generateClassCode() {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    return List.generate(
      6,
      (_) => characters[
          random.nextInt(characters.length)],
    ).join();
  }

  /// Allows a student to join a classroom using a class code.
  Future<String?> joinClassroom({
    required String studentId,
    required String classCode,
  }) async {
    try {
      // Find the classroom by code
      final classroom = await _supabase
          .from('classrooms')
          .select()
          .eq(
            'class_code',
            classCode.trim().toUpperCase(),
          )
          .maybeSingle();

      if (classroom == null) {
        return 'Classroom not found.';
      }

      // Insert enrollment record
      await _supabase
          .from('enrollments')
          .insert({
        'student_id': studentId,
        'classroom_id': classroom['id'],
      });

      return null; // Success
    } catch (e) {
      // Prevent duplicate enrollment errors
      if (e
              .toString()
              .toLowerCase()
              .contains('duplicate') ||
          e
              .toString()
              .toLowerCase()
              .contains('unique')) {
        return 'You have already joined this classroom.';
      }

      return e.toString();
    }
  }

  /// Returns all classrooms that a student has joined.
  /// Uses Supabase realtime instead of polling,
  /// so the UI no longer refreshes every 2 seconds.
  Stream<List<ClassroomModel>>
      getStudentClassrooms(String studentId) {
    return _supabase
        .from('enrollments')
        .stream(primaryKey: ['id'])
        .eq('student_id', studentId)
        .asyncMap((enrollments) async {
          // If no enrollments exist, return empty list
          if (enrollments.isEmpty) {
            return <ClassroomModel>[];
          }

          // Extract classroom IDs
          final classroomIds = enrollments
              .map((e) => e['classroom_id'])
              .toList();

          // Fetch matching classrooms
          final classrooms = await _supabase
              .from('classrooms')
              .select()
              .inFilter('id', classroomIds)
              .order(
                'created_at',
                ascending: false,
              );

          // Convert to ClassroomModel objects
          return classrooms
              .map<ClassroomModel>(
                (row) =>
                    ClassroomModel.fromMap(row),
              )
              .toList();
        });
  }

  /// Saves a material record to the database.
  Future<void> addMaterial(
      MaterialModel material) async {
    await _supabase
        .from('materials')
        .insert(material.toMap());
  }

  /// Retrieves all materials for a specific classroom in real time.
  Stream<List<MaterialModel>> getMaterials(
      String classroomId) {
    return _supabase
        .from('materials')
        .stream(primaryKey: ['id'])
        .eq('classroom_id', classroomId)
        .order(
          'created_at',
          ascending: false,
        )
        .map(
          (rows) => rows
              .map(
                (row) =>
                    MaterialModel.fromMap(row),
              )
              .toList(),
        );
  }

  /// Deletes a material record from the database.
  Future<void> deleteMaterial(
      String materialId) async {
    await _supabase
        .from('materials')
        .delete()
        .eq('id', materialId);
  }
}