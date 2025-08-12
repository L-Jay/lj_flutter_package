import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

class LJImagePreviewPage extends StatefulWidget {
  /// 支持url/path
  final List<String> images;

  const LJImagePreviewPage({super.key, required this.images});

  @override
  State<LJImagePreviewPage> createState() => _LJImagePreviewPageState();
}

class _LJImagePreviewPageState extends State<LJImagePreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PageView.builder(
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          var url = widget.images[index];
          return url.startsWith('http')
              ? LJNetworkImage(url: url)
              : Image.file(File(url));
        },
      ),
    );
  }
}
