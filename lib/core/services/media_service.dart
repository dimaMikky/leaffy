import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class MediaService extends GetxService {
  final ImagePicker _picker = ImagePicker();

  // Pick an image from gallery
  Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 80,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Pick multiple images from gallery
  Future<List<File>> pickMultipleImages({
    int imageQuality = 80,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      return pickedFiles.map((file) => File(file.path)).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return [];
    }
  }

  // Compress an image file
  Future<File?> compressImage(File file, {int quality = 80}) async {
    try {
      final String dir = (await getTemporaryDirectory()).path;
      final String targetPath =
          path.join(dir, '${DateTime.now().millisecondsSinceEpoch}.jpg');

      // For real implementation, you'd want to use a proper image compression library
      // This is a simplified version for demo purposes
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error compressing image: $e');
      return file; // Return original if compression fails
    }
  }

  // Download an image from a URL
  Future<File?> downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final String dir = (await getTemporaryDirectory()).path;
        final String fileName = path.basename(imageUrl);
        final String filePath = path.join(dir, fileName);

        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return file;
      }
      return null;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }
}

// Mock class for image compression - in real app, use a proper library like flutter_image_compress
class FlutterImageCompress {
  static Future<File?> compressAndGetFile(
    String sourcePath,
    String targetPath, {
    int quality = 80,
  }) async {
    try {
      final File sourceFile = File(sourcePath);
      final File targetFile = File(targetPath);

      await targetFile.writeAsBytes(await sourceFile.readAsBytes());
      return targetFile;
    } catch (e) {
      return null;
    }
  }
}
