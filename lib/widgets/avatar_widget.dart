import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lj_flutter_package/ui_component/lj_network_image.dart';
import 'package:lj_flutter_package/utils/lj_define.dart';
import 'package:lj_flutter_package/utils/lj_util.dart';

class AvatarWidget extends StatefulWidget {
  final double size;
  final String imageUrl;
  final Color borderColor;
  final double borderWidth;
  final bool showCamera;
  final Widget? cameraWidget;
  final bool userFront;
  final bool crop;
  final Function(String? imagePath)? pickFinish;

  const AvatarWidget({
    super.key,
    required this.size,
    required this.imageUrl,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.showCamera = false,
    this.userFront = false,
    this.crop = false,
    this.cameraWidget,
    this.pickFinish,
  });

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.showCamera) {
      return GestureDetector(
        onTap: () async {
          int? index = await showActionSheet(
              Get.context!, Platform.isIOS ? ['相机', '相册'] : ['相册']);
          if (index != null && widget.pickFinish != null) {
            var imagePath = await LJUtil.pickerImage(
              useCamera: index == 0,
              userFront: widget.userFront,
              crop: widget.crop,
            );
            widget.pickFinish!(imagePath);
          }
        },
        child: _buildContent(),
      );
    }

    return _buildContent();
  }

  Widget _buildContent() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          LJNetworkImage(
            width: widget.size,
            height: widget.size,
            url: widget.imageUrl,
            borderColor: widget.borderColor,
            borderWidth: widget.borderWidth,
            radius: (widget.size - widget.borderWidth) * 0.5,
          ),
          if (widget.showCamera)
            Positioned(
              right: 0,
              bottom: 0,
              child: widget.cameraWidget ??
                  quickContainer(
                    width: widget.size * 0.30,
                    height: widget.size * 0.30,
                    circular: widget.size * 0.30 * 0.5,
                    color: Colors.white,
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: widget.size * 0.25,
                    ),
                  ),
            ),
        ],
      ),
    );
  }
}
