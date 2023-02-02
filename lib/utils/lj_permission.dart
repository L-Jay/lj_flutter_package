import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class LJPermissionUtils {
  static Future<bool> checkStorage() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();

        return status.isGranted;
      }

      return true;
    } else {
      return true;
    }
  }

  static Future<bool> checkCamera() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();

      return status.isGranted;
    }

    return true;
  }

  static Future<bool> checkPhotos() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();

      return status.isGranted;
    }

    return true;
  }

  static Future<bool> checkMicrophone() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();

      return status.isGranted;
    }

    return true;
  }
}