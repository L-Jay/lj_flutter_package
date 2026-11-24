import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class LJPermissionUtils {
  static Future<bool> checkStorage() async {
    if (Platform.isAndroid) {
      // Android 13+ 存储权限已按媒体类型拆分（Permission.storage 恒为 denied），
      // 选图走系统 Photo Picker，本身不需要存储权限，直接放行
      final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 33) return true;

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