import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Creates a new announcement.
  Future<void> addAnnouncement(
    AnnouncementModel announcement,
  ) async {
    await _supabase
        .from('announcements')
        .insert(announcement.toMap());
  }

  /// Updates an existing announcement.
  Future<void> updateAnnouncement(
    AnnouncementModel announcement,
  ) async {
    await _supabase
        .from('announcements')
        .update(announcement.toMap())
        .eq('id', announcement.id);
  }

  /// Deletes an announcement from the database.
  Future<void> deleteAnnouncement(
    String announcementId,
  ) async {
    await _supabase
        .from('announcements')
        .delete()
        .eq('id', announcementId);
  }

  /// Returns announcements for a specific classroom in real time.
  Stream<List<AnnouncementModel>> getAnnouncements(
    String classroomId,
  ) {
    return _supabase
        .from('announcements')
        .stream(primaryKey: ['id'])
        .eq('classroom_id', classroomId)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows
              .map(
                (row) =>
                    AnnouncementModel.fromMap(row),
              )
              .toList(),
        );
  }
}