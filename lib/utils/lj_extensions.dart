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

/// 尺寸 / 安全区扩展，StatefulWidget 与 StatelessWidget 通用：
/// - StatefulWidget：State 内直接用 `safeBottom`、`screenWidth`（省掉 context）
/// - StatelessWidget：`context.safeBottom`、`context.screenWidth`
///
/// `safeArea` / `safeTop` / `safeBottom` 取的是物理安全区（viewPadding），
/// 不受键盘影响，键盘弹起/收起时数值稳定。
///
/// 注意：`SafeArea` / `BottomContainer` 内部依然会返回真实安全区值
/// （SafeArea 只移除 MediaQuery 的 padding，不动 viewPadding），
/// 已经由它们处理过的区域不要再叠加一次，否则会出现双份留白。
extension BuildContextExtension on BuildContext {
  /// 物理安全区：状态栏、刘海、home indicator 等系统 UI 遮挡区域
  EdgeInsets get safeArea {
    return MediaQuery.viewPaddingOf(this);
  }

  double get safeTop {
    return safeArea.top;
  }

  double get safeBottom {
    return safeArea.bottom;
  }

  double get safeLeft {
    return safeArea.left;
  }

  double get safeRight {
    return safeArea.right;
  }

  /// 键盘遮挡区域（横屏时键盘可能占 left/right）
  EdgeInsets get keyboardInset {
    return MediaQuery.viewInsetsOf(this);
  }

  /// 键盘占用高度，键盘收起时为 0
  double get keyboardHeight {
    return keyboardInset.bottom;
  }

  /// 整窗宽度（含被系统 UI 覆盖的部分，不是可用区域）
  double get screenWidth {
    return MediaQuery.sizeOf(this).width;
  }

  /// 整窗高度（同上，键盘弹起时不变）
  double get screenHeight {
    return MediaQuery.sizeOf(this).height;
  }

  // ==================== 旧命名，保留过渡，后续版本删除 ====================

  /// 受键盘影响的安全区（键盘弹起时 bottom 会被扣成 0）
  @Deprecated('改用 safeArea（物理安全区）或 keyboardHeight（键盘高度）')
  EdgeInsets get padding {
    return MediaQuery.paddingOf(this);
  }

  @Deprecated('改用 safeTop')
  double get top {
    return safeTop;
  }

  @Deprecated('改用 safeBottom')
  double get bottom {
    return safeBottom;
  }

  @Deprecated('改用 safeLeft')
  double get left {
    return safeLeft;
  }

  @Deprecated('改用 safeRight')
  double get right {
    return safeRight;
  }

  @Deprecated('改用 screenWidth')
  double get width {
    return screenWidth;
  }

  @Deprecated('改用 screenHeight')
  double get height {
    return screenHeight;
  }
}

extension StateExtension on State {
  EdgeInsets get safeArea {
    return context.safeArea;
  }

  double get safeTop {
    return context.safeTop;
  }

  double get safeBottom {
    return context.safeBottom;
  }

  double get safeLeft {
    return context.safeLeft;
  }

  double get safeRight {
    return context.safeRight;
  }

  EdgeInsets get keyboardInset {
    return context.keyboardInset;
  }

  double get keyboardHeight {
    return context.keyboardHeight;
  }

  double get screenWidth {
    return context.screenWidth;
  }

  double get screenHeight {
    return context.screenHeight;
  }

  // ==================== 旧命名，保留过渡，后续版本删除 ====================

  @Deprecated('改用 safeArea（物理安全区）或 keyboardHeight（键盘高度）')
  EdgeInsets get padding {
    return MediaQuery.paddingOf(context);
  }

  @Deprecated('改用 safeTop')
  double get top {
    return context.safeTop;
  }

  @Deprecated('改用 safeBottom')
  double get bottom {
    return context.safeBottom;
  }

  @Deprecated('改用 safeLeft')
  double get left {
    return context.safeLeft;
  }

  @Deprecated('改用 safeRight')
  double get right {
    return context.safeRight;
  }

  @Deprecated('改用 screenWidth')
  double get width {
    return context.screenWidth;
  }

  @Deprecated('改用 screenHeight')
  double get height {
    return context.screenHeight;
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
