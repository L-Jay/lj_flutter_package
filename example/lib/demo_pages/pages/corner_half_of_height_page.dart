import 'package:example/common/lj_colors.dart';
import 'package:flutter/material.dart';
import 'package:lj_flutter_package/ui_component/lj_custom_clipper.dart';

class CornerHalfOfHeightPage extends StatefulWidget {
  const CornerHalfOfHeightPage({Key? key}) : super(key: key);

  @override
  State<CornerHalfOfHeightPage> createState() => _CornerHalfOfHeightPageState();
}

class _CornerHalfOfHeightPageState extends State<CornerHalfOfHeightPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ClipPath(
          clipper: LJHalfCornerClipper(),
          child: Container(
            width: 200,
            height: 40,
            color: LJColor.mainColor,
          ),
        ),
      ),
    );
  }
}
