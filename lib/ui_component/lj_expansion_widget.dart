import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';

/// context，BuildContext
/// expandNotifier, 展开状态
/// toggleExpand，展开、收起方法
typedef LJExpansionWidgetBuilder = Widget Function(
    BuildContext context,
    ValueNotifier<bool> expandNotifier,
    VoidCallback toggleExpand,
    );

class LJExpansionWidget extends StatefulWidget {
  /// headerBuilder，点击展开
  final LJExpansionWidgetBuilder headerBuilder;

  /// childBuilder，展开显示的内容
  final LJExpansionWidgetBuilder childBuilder;

  /// isExpand是否展开状态
  final bool isExpand;

  /// stickyHeader child头部是否悬停
  final bool stickyHeader;

  /// maintainState保持子组件状态
  final bool maintainState;

  /// headerCanClick整个header可以响应点击展开、收起
  /// false,可在headerBuilder调用张开、收起操作
  final bool headerCanClick;

  /// onExpansionChanged展开折叠回调
  final Function(bool expand)? onExpansionChanged;

  LJExpansionWidget({
    Key? key,
    required this.headerBuilder,
    required this.childBuilder,
    this.isExpand = false,
    this.stickyHeader = false,
    this.maintainState = true,
    this.headerCanClick = true,
    this.onExpansionChanged,
  }) : super(key: key);

  @override
  _LJExpansionWidgetState createState() => _LJExpansionWidgetState();
}

class _LJExpansionWidgetState extends State<LJExpansionWidget>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
  CurveTween(curve: Curves.easeIn);

  late AnimationController _animationController;
  late Animation<double> _heightFactor;

  final ValueNotifier<bool> _expandNotifier = ValueNotifier(false);

  late VoidCallback expandCallback;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _heightFactor = _animationController.drive(_easeInTween);

    _expandNotifier.value =
        PageStorage.maybeOf(context)?.readState(context) as bool? ??
            widget.isExpand;

    if (_expandNotifier.value) _animationController.value = 1.0;

    expandCallback = () {
      _handleTap();
    };
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _expandNotifier.value = !_expandNotifier.value;
      if (_expandNotifier.value) {
        _animationController.forward();
      } else {
        _animationController.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.maybeOf(context)?.writeState(context, _expandNotifier);
    });
    widget.onExpansionChanged?.call(_expandNotifier.value);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    Widget header = LayoutBuilder(
      builder: (context, _) => widget.headerBuilder(
        context,
        _expandNotifier,
        expandCallback,
      ),
    );

    if (widget.headerCanClick) {
      header = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _handleTap,
        child: header,
      );
    }

    Widget content = ClipRect(
      child: Align(
        heightFactor: _heightFactor.value,
        child: child,
      ),
    );

    if (widget.stickyHeader) {
      return StickyHeader(
        header: header,
        content: content,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        header,
        content,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed =
        !_expandNotifier.value && _animationController.isDismissed;
    final bool shouldRemoveChildren = closed && !widget.maintainState;

    final Widget result = Offstage(
      offstage: closed,
      child: TickerMode(
        enabled: !closed,
        child: LayoutBuilder(
          builder: (context, _) =>
              widget.childBuilder(context, _expandNotifier, expandCallback),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _animationController.view,
      builder: _buildChildren,
      child: shouldRemoveChildren ? null : result,
    );
  }
}
