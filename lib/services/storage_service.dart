import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

    // Upload file bytes
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

  /// Downloads and opens a file.
  /// On Flutter Web, opens the file directly in a new browser tab.
  /// On mobile/desktop, downloads the file and opens it locally.
  Future<void> downloadAndOpenMaterial({
    required String fileUrl,
    required String fileName,
  }) async {
    try {
      // Flutter Web: open directly in a new browser tab
      if (kIsWeb) {
        final uri = Uri.parse(fileUrl);

        final launched = await launchUrl(
          uri,
          webOnlyWindowName: '_blank',
        );

        if (!launched) {
          throw Exception('Could not open the file.');
        }

        return;
      }

      // Mobile/Desktop: download to local storage and open
      final directory =
          await getApplicationDocumentsDirectory();

      final filePath =
          '${directory.path}/$fileName';

      await Dio().download(fileUrl, filePath);

      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('Downloaded file not found.');
      }

      if (await file.length() == 0) {
        throw Exception('Downloaded file is empty.');
      }

      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      throw Exception('Could not open the file: $e');
    }
  }

  /// Deletes ONLY the file from the `materials` storage bucket.
  /// The corresponding database row should be deleted
  /// separately using ClassroomService.deleteMaterial().
  Future<void> deleteMaterial(String fileUrl) async {
    final uri = Uri.parse(fileUrl);

    // Public URLs contain:
    // .../storage/v1/object/public/materials/<path>
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