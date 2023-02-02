import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';

typedef LJExpansionWidgetHeaderBuilder = Widget Function(BuildContext context, bool isExpand);

class LJExpansionWidget extends StatefulWidget {
  /// header，点击展开
  final LJExpansionWidgetHeaderBuilder headerBuilder;

  /// children，展开显示的内容
  final List<Widget> children;

  /// isExpand是否展开状态
  final bool isExpand;

  /// stickyHeader child头部是否悬停
  final bool stickyHeader;

  /// onExpansionChanged展开折叠回调
  final Function(bool expand)? onExpansionChanged;

  const LJExpansionWidget({
    Key? key,
    required this.headerBuilder,
    this.children = const [],
    this.isExpand = false,
    this.onExpansionChanged,
    this.stickyHeader = false,
  }) : super(key: key);

  @override
  State<LJExpansionWidget> createState() => _LJExpansionWidgetState();
}

class _LJExpansionWidgetState extends State<LJExpansionWidget>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
  CurveTween(curve: Curves.easeIn);

  late AnimationController _animationController;
  late Animation<double> _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _heightFactor = _animationController.drive(_easeInTween);

    _isExpanded =
        PageStorage.of(context)?.readState(context) as bool? ?? widget.isExpand;

    if (_isExpanded) _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    if (widget.stickyHeader) {
      return StickyHeader(
        header: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _handleTap,
          child: LayoutBuilder(
            builder: (context, _) => widget.headerBuilder(context, _isExpanded),
          ),
        ),
        content: ClipRect(
          child: Align(
            heightFactor: _heightFactor.value,
            child: child,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _handleTap,
          child: LayoutBuilder(
            builder: (context, _) => widget.headerBuilder(context, _isExpanded),
          ),
        ),
        ClipRect(
          child: Align(
            heightFactor: _heightFactor.value,
            child: child,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _animationController.isDismissed;
    return AnimatedBuilder(
      animation: _animationController.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}
