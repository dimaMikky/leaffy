import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class FileService extends GetxService {
  final SupabaseClient _client = Supabase.instance.client;

  // Upload file using bytes (works on all platforms)
  Future<String> uploadFile({
    required String bucketName,
    required String fileName,
    required Uint8List bytes,
    String? contentType,
  }) async {
    try {
      // Create a unique filename to avoid collisions
      final fileExtension = path.extension(fileName).isNotEmpty
          ? path.extension(fileName)
          : '.jpg';
      final uniqueFileName = '${const Uuid().v4()}$fileExtension';

      // Upload the file
      await _client.storage.from(bucketName).uploadBinary(
            uniqueFileName,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType ?? _getContentType(fileExtension),
            ),
          );

      // Get the public URL
      final String publicUrl =
          _client.storage.from(bucketName).getPublicUrl(uniqueFileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload file: ${e.toString()}');
    }
  }

  // Delete file from storage
  Future<void> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      await _client.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      // If the file doesn't exist, we don't need to throw an error
      print('Warning: Failed to delete file: ${e.toString()}');
    }
  }

  // Extract file name from URL
  String getFileNameFromUrl(String url) {
    try {
      // Extract the filename from the URL
      return url.split('/').last;
    } catch (e) {
      print('Warning: Could not parse filename from URL: $url');
      return const Uuid().v4(); // Return a random name if we can't parse
    }
  }

  // Get content type based on file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.svg':
        return 'image/svg+xml';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
      case '.docx':
        return 'application/msword';
      case '.xls':
      case '.xlsx':
        return 'application/vnd.ms-excel';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream'; // Default binary content type
    }
  }
}
