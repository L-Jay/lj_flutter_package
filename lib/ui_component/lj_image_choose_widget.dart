import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lj_flutter_package/ui_component/lj_image_preview_page.dart';
import 'package:lj_flutter_package/utils/lj_define.dart';
import 'package:lj_flutter_package/utils/lj_router_manager.dart';
import 'package:lj_flutter_package/utils/lj_util.dart';

class LJImageChooseWidget extends StatefulWidget {
  final int imageCount;
  final double size;
  final double? corner;
  final Color backgroundColor;
  final double borderWidth;
  final Color? borderColor;
  final Function(List<String> imagePaths) selectedImages;

  const LJImageChooseWidget({
    super.key,
    this.imageCount = 1,
    this.size = 66,
    this.corner,
    this.backgroundColor = Colors.white30,
    this.borderWidth = 0,
    this.borderColor,
    required this.selectedImages,
  });

  @override
  State<LJImageChooseWidget> createState() => _LJImageChooseWidgetState();
}

class _LJImageChooseWidgetState extends State<LJImageChooseWidget> {
  final List<String> _imagePaths = [];

  _selectImage() async {
    int? index =
        await showActionSheet(context, Platform.isIOS ? ['相机', '相册'] : ['相册']);
    if (index != null) {
      var imagePath = await LJUtil.pickerImage(useCamera: index == 0);

      if (imagePath?.isNotEmpty == true) {
        setState(() {
          _imagePaths.add(imagePath!);
        });

        widget.selectedImages(_imagePaths);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var images = _imagePaths.map((path) {
      return GestureDetector(
        onTap: () => Navigator.of(context)
            .push(pageRoute(LJImagePreviewPage(images: _imagePaths))),
        onLongPress: () async {
          int? index = await showActionSheet(context, ['删除']);
          if (index != null) {
            setState(() {
              _imagePaths.remove(path);
            });

            widget.selectedImages(_imagePaths);
          }
        },
        child: quickContainer(
          color: widget.backgroundColor,
          width: widget.size,
          height: widget.size,
          circular: widget.corner,
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            width: widget.size,
            height: widget.size,
          ),
        ),
      );
    }).toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...images,
        if (_imagePaths.length < widget.imageCount)
          GestureDetector(
            onTap: _selectImage,
            child: quickContainer(
              color: widget.backgroundColor,
              width: widget.size,
              height: widget.size,
              borderWidth: widget.borderWidth,
              borderColor: widget.borderColor,
              circular: widget.corner,
              child: Icon(
                Icons.add,
                color: widget.backgroundColor.withOpacity(0.5),
                size: widget.size * 0.5,
              ),
            ),
          ),
      ],
    );
  }
}
