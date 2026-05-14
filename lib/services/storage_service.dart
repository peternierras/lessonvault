import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Uploads a file to the `materials` bucket and returns the public URL.
  /// Works on Flutter Web, Android, iOS, Windows, macOS, and Linux.
  Future<String> uploadMaterial({
    required PlatformFile file,
    required String classroomId,
  }) async {
    // Use the original filename
    final originalFileName = file.name;

    // Create a unique filename using timestamp
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_$originalFileName';

    // Store files inside a folder for each classroom
    final storagePath = '$classroomId/$fileName';

    // Upload depending on platform:
    // - Web uses bytes
    // - Mobile/Desktop uses bytes if available
    if (file.bytes != null) {
      await _supabase.storage
          .from('materials')
          .uploadBinary(storagePath, file.bytes!);
    } else {
      throw Exception(
        'Unable to read the selected file. Please reselect the file and try again.',
      );
    }

    // Return the public URL
    return _supabase.storage
        .from('materials')
        .getPublicUrl(storagePath);
  }

  /// Deletes a file from the `materials` storage bucket using its public URL.
  Future<void> deleteMaterial(String fileUrl) async {
    final uri = Uri.parse(fileUrl);

    // Public URLs contain ".../storage/v1/object/public/materials/<path>"
    const marker = '/materials/';
    final index = uri.path.indexOf(marker);

    if (index == -1) {
      throw Exception('Invalid storage URL.');
    }

    // Extract the relative storage path
    final storagePath =
        uri.path.substring(index + marker.length);

    // Delete the file from Supabase Storage
    await _supabase.storage
        .from('materials')
        .remove([storagePath]);
  }
}