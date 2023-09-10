import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageServices {
  final _storage = FirebaseStorage.instance;

  updateProfileImage(
      File file,
      String uid,
      void Function(double) updateProgress,
      void Function(String) updateData) async {
    Uint8List imageData = await XFile(file.path).readAsBytes();
    final uploadTask = _storage.ref("users/$uid").putData(imageData);
    uploadTask.snapshotEvents.listen((event) async {
      switch (event.state) {
        case TaskState.running:
          final progress = 100.0 * (event.bytesTransferred / event.totalBytes);
          updateProgress(progress);
          break;
        case TaskState.paused:
          break;
        case TaskState.canceled:
          break;
        case TaskState.error:
          break;
        case TaskState.success:
          String downloadUrl =
              await _storage.ref("users/$uid").getDownloadURL();
          updateData(downloadUrl);
          break;
      }
    });
  }
}
