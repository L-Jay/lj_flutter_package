import 'package:flutter/material.dart';

class LJDashedLine extends StatelessWidget {
  final double dashedWidth;
  final Color dashedColor;

  /// 虚线间隔,不指定默认跟dashedWidth一样
  final double? spaceWidth;
  final double? height;

  const LJDashedLine({
    super.key,
    required this.dashedWidth,
    required this.dashedColor,
    this.spaceWidth,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var width = constraints.constrainWidth();
        var space = spaceWidth ?? dashedWidth;
        int count = width ~/ (dashedWidth + space) + 10;

        return SizedBox(
          height: height ?? constraints.constrainHeight(),
          child: Wrap(
            clipBehavior: Clip.hardEdge,
            children: List.generate(count, (index) {
              return Container(
                margin: EdgeInsets.only(right: space),
                height: height,
                width: dashedWidth,
                color: dashedColor,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
