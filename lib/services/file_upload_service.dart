import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Pick and validate MP4 video file
  Future<PlatformFile?> pickVideoFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        // Validate file size (e.g., max 100MB)
        if (file.size > 100 * 1024 * 1024) {
          throw Exception('File size must be less than 100MB');
        }

        return file;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  /// Upload video file to Firebase Storage
  Future<String> uploadVideoFile(PlatformFile file, String userId) async {
    try {
      // Create unique file name
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      String path = 'videos/$userId/$fileName';

      Reference ref = _storage.ref().child(path);

      // Upload file
      UploadTask uploadTask;
      if (file.bytes != null) {
        // Web platform
        uploadTask = ref.putData(file.bytes!);
      } else {
        // Mobile platforms
        File localFile = File(file.path!);
        uploadTask = ref.putFile(localFile);
      }

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  /// Get upload progress stream
  Stream<TaskSnapshot> getUploadProgress(UploadTask uploadTask) {
    return uploadTask.snapshotEvents;
  }
}