import 'package:flutter/material.dart';

class DoublePopWidget extends StatefulWidget {
  final Widget child;

  /// 第一次返回回调
  final VoidCallback? firstCallBack;

  const DoublePopWidget({super.key, required this.child, this.firstCallBack});

  @override
  State<DoublePopWidget> createState() => _DoublePopWidgetState();
}

class _DoublePopWidgetState extends State<DoublePopWidget> {
  DateTime? _lastTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_lastTime == null) {
          _lastTime = DateTime.now();
          widget.firstCallBack?.call();

          return false;
        } else {
          int diff = DateTime.now().difference(_lastTime!).inMilliseconds;
          _lastTime = DateTime.now();
          if (diff > 1000) widget.firstCallBack?.call();
          return diff <= 1000;
        }
      },
      child: widget.child,
    );
  }
}
