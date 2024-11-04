import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lj_event_bus.dart';
import 'lj_permission.dart';

class LJUtil {
  static late SharedPreferences preferences;
  static late PackageInfo packageInfo;
  static late AndroidDeviceInfo androidDeviceInfo;
  static late IosDeviceInfo iosDeviceInfo;
  static late LJEventBus eventBus;
  static bool isEnglish = false;

  static Future<bool> initInstance() async {
    preferences = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) androidDeviceInfo = await deviceInfo.androidInfo;
    if (Platform.isIOS) iosDeviceInfo = await deviceInfo.iosInfo;
    eventBus = LJEventBus();
    return true;
  }

  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickerImage({
    bool useCamera = true,
    bool? crop,
    bool userFront = false,
  }) async {
    bool permission = await LJPermissionUtils.checkStorage();
    if (!permission) return null;

    if (useCamera) {
      permission = await LJPermissionUtils.checkCamera();
    } else {
      permission = await LJPermissionUtils.checkPhotos();
    }

    if (!permission) return null;

    XFile? file = await _picker.pickImage(
      source: useCamera ? ImageSource.camera : ImageSource.gallery,
      preferredCameraDevice: userFront ? CameraDevice.front : CameraDevice.rear,
    );
    // PickedFile file = await ImagePicker.platform.pickImage(
    //   source: useCamera ? ImageSource.camera : ImageSource.gallery,
    //   preferredCameraDevice: userFront ? CameraDevice.front : CameraDevice.rear,
    // );

    if (file == null) return null;

    if (crop == null || !crop) {
      return file.path;
    } else {
      return await cropImage(file.path);
    }
  }

  static Future<String?> cropImage(
    String imagePath, {
    double ratioX = 1,
    double ratioY = 1,
  }) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: CropAspectRatio(
        ratioX: ratioX,
        ratioY: ratioY,
      ),
      // aspectRatioPresets: [
      //   CropAspectRatioPreset.square,
      // ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: isEnglish ? 'Tailoring' : "剪裁",
          toolbarColor: Colors.transparent,
          // toolbarWidgetColor: Colors.transparent,
          // initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
          hideBottomControls: true,
          cropGridRowCount: 0,
          cropGridColumnCount: 0,
        ),
        IOSUiSettings(
          title: isEnglish ? 'Tailoring' : '剪裁',
          cancelButtonTitle: isEnglish ? 'Cancel' : '取消',
          doneButtonTitle: isEnglish ? 'Done' : '完成',
        ),
      ],
      compressQuality: 100,
      cropStyle: CropStyle.rectangle,
    );

    return croppedFile?.path;
  }
}
