import 'package:flutter/widgets.dart';

class BottomContainer extends StatelessWidget {
  final double height;
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;

  const BottomContainer({
    Key? key,
    required this.height,
    required this.child,
    this.color,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      height: height + bottom,
      color: color,
      alignment: Alignment.topCenter,
      child: Container(
        height: height,
        padding: padding,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
