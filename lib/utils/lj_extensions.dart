import 'package:flutter/widgets.dart';
import 'package:date_format/date_format.dart' as dataFormat;

extension StringExtensions on String {
  int toInt() {
    return int.parse(this);
  }

  double toDouble() {
    return double.parse(this);
  }

  bool verifyPhone() {
    RegExp exp = RegExp(
        r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    bool matched = exp.hasMatch(this);

    return matched;
  }
}

extension intToDate on int {
  String toDate({bool hideSecond = false, bool hideHour = false}) {
    if (hideHour) hideSecond = true;

    DateTime time = DateTime.fromMillisecondsSinceEpoch(this);
    String timeStr = dataFormat.formatDate(time, [
      dataFormat.yyyy,
      ".",
      dataFormat.mm,
      ".",
      dataFormat.dd,
      if (!hideHour) " ",
      if (!hideHour) dataFormat.HH,
      if (!hideHour) ":",
      if (!hideHour) dataFormat.nn,
      if (!hideSecond) ":",
      if (!hideSecond) dataFormat.ss,
    ]);

    return timeStr;
  }
}

extension StateExtension on State {
  EdgeInsets get padding {
    return MediaQuery.of(context).viewPadding;
  }

  double get top {
    return MediaQuery.of(context).viewPadding.top;
  }

  double get bottom {
    return MediaQuery.of(context).viewPadding.bottom;
  }

  double get left {
    return MediaQuery.of(context).viewPadding.left;
  }

  double get right {
    return MediaQuery.of(context).viewPadding.right;
  }

  double get width {
    return MediaQuery.of(context).size.width;
  }

  double get height {
    return MediaQuery.of(context).size.height;
  }
}

extension JionExtension<T> on List<T> {
  List<T> joinObject(T object) {
    var list = expand((element) => [element, object]).toList();
    list.removeLast();

    return list;
  }
}

// ==================== 通用交互底层 ====================
class _TappableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedOpacity;
  final double disabledOpacity;
  final HitTestBehavior behavior;

  const _TappableWidget({
    required this.child,
    this.onTap,
    this.onLongPress,
    required this.pressedOpacity,
    required this.disabledOpacity,
    required this.behavior,
  });

  @override
  State<_TappableWidget> createState() => _TappableWidgetState();
}

class _TappableWidgetState extends State<_TappableWidget> {
  bool _isPressed = false;
  bool get _isDisabled => widget.onTap == null && widget.onLongPress == null;

  @override
  Widget build(BuildContext context) {
    final double opacity = _isDisabled
        ? widget.disabledOpacity
        : (_isPressed ? widget.pressedOpacity : 1.0);

    return GestureDetector(
      onTap: _isDisabled ? null : widget.onTap,
      onLongPress: _isDisabled ? null : widget.onLongPress,
      onTapDown: _isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: _isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: _isDisabled ? null : () => setState(() => _isPressed = false),
      behavior: widget.behavior,
      child: Opacity(
        opacity: opacity,
        child: widget.child,
      ),
    );
  }
}

// ==================== Widget 通用点击扩展 ====================
extension WidgetTapExtension on Widget {
  Widget onTap(
      VoidCallback? onTap, {
        VoidCallback? onLongPress,
        double pressedOpacity = 1.0, // 默认无按下效果
        double disabledOpacity = 1.0, // 默认禁用不改样式
        HitTestBehavior behavior = HitTestBehavior.opaque,
      }) {
    if (pressedOpacity >= 1.0 && disabledOpacity >= 1.0) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        behavior: behavior,
        child: this,
      );
    }

    return _TappableWidget(
      onTap: onTap,
      onLongPress: onLongPress,
      pressedOpacity: pressedOpacity,
      disabledOpacity: disabledOpacity,
      behavior: behavior,
      child: this,
    );
  }
}

// ==================== Text 专属点击扩展 ====================
extension TextTapExtension on Text {
  /// 给 Text 添加点击能力，默认自带按下变暗+禁用降灰
  Widget onTap(
      VoidCallback? onTap, {
        VoidCallback? onLongPress,
        double pressedOpacity = 0.7, // 默认文字按下变暗
        double disabledOpacity = 0.5, // 默认文字禁用降灰
        HitTestBehavior behavior = HitTestBehavior.opaque,
      }) {
    return _TappableWidget(
      onTap: onTap,
      onLongPress: onLongPress,
      pressedOpacity: pressedOpacity,
      disabledOpacity: disabledOpacity,
      behavior: behavior,
      child: this,
    );
  }
}
