import 'package:example/common/lj_colors.dart';
import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';
import 'package:lj_flutter_package/ui_component/lj_drag_container.dart';

class DragDemoPage extends StatefulWidget {
  const DragDemoPage({Key? key}) : super(key: key);

  @override
  State<DragDemoPage> createState() => _DragDemoPageState();
}

class _DragDemoPageState extends State<DragDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          color: Colors.blueAccent,
          child: Stack(
            children: [
              LJDragContainer(
                adsorption: LJDragAdsorption.all,
                child: quickText('拖我', 15, LJColor.mainColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
