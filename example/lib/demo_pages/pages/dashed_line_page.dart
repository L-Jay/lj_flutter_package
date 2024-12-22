import 'package:flutter/material.dart';
import 'package:lj_flutter_package/ui_component/lj_dashed_line.dart';

class DashedLinePage extends StatelessWidget {
  const DashedLinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LJDashedLine(
          dashedWidth: 10,
          dashedColor: Colors.orange,
          height: 4,
        ),
      ],
    );
  }
}
