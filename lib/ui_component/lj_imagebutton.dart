import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ImageButtonPosition { left, up, right, bottom }

enum ImageTextAlign { centerLeft, center, centerRight }

enum ImageButtonState {
  normal,
  highlight,
  selected,
  disable,
}

class LJImageButton extends StatefulWidget {
  const LJImageButton({
    Key? key,
    required this.imageChild,
    required this.textChild,
    this.padding,
    this.width,
    this.height,
    this.alignment,
    this.decoration,
    this.backgroundColor,
    this.highlightImageChild,
    this.highlightTextChild,
    this.highlightBackgroundColor,
    this.selectedImageChild,
    this.selectedTextChild,
    this.selectedBackgroundColor,
    this.disableImageChild,
    this.disableTextChild,
    this.disableBackgroundColor,
    this.spaceMargin = 0,
    this.position = ImageButtonPosition.left,
    this.state = ImageButtonState.normal,
    this.onTap,
    this.imageAnimationBegin,
    this.imageAnimationEnd,
    this.forwardOrReverseValueNotifier,
    this.imageTextAlign = ImageTextAlign.center,
  }) : super(key: key);

  final EdgeInsets? padding;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;
  final Alignment? alignment;
  final Widget textChild;
  final Widget imageChild;
  final Color? backgroundColor;
  final Widget? highlightImageChild;
  final Widget? highlightTextChild;
  final Color? highlightBackgroundColor;
  final Widget? selectedImageChild;
  final Widget? selectedTextChild;
  final Color? selectedBackgroundColor;
  final Widget? disableImageChild;
  final Widget? disableTextChild;
  final Color? disableBackgroundColor;
  final double? spaceMargin;
  final ImageButtonPosition position;
  final ImageButtonState state;
  final GestureTapCallback? onTap;
  final double? imageAnimationBegin;
  final double? imageAnimationEnd;
  final ValueNotifier<bool>? forwardOrReverseValueNotifier;
  final ImageTextAlign imageTextAlign;

  @override
  State<LJImageButton> createState() => _LJImageButtonState();
}

class _LJImageButtonState extends State<LJImageButton>
    with SingleTickerProviderStateMixin {
  late ImageButtonState _state;
  late ImageButtonState _lastState;

  AnimationController? _animationController;
  Animation<double>? _animation;
  late ValueNotifier<bool> _valueNotifier;

  @override
  void initState() {
    super.initState();

    _state = widget.state;

    _valueNotifier = widget.forwardOrReverseValueNotifier ?? ValueNotifier(false);

    if (widget.imageAnimationBegin != null &&
        widget.imageAnimationEnd != null) {
      _animationController = AnimationController(
          duration: const Duration(milliseconds: 300), vsync: this);
      _animation = Tween(
          begin: widget.imageAnimationBegin, end: widget.imageAnimationEnd)
          .animate(_animationController!);

      _valueNotifier.addListener(() {
        setState(() {
          _valueNotifier.value ?
          _animationController?.forward() :
          _animationController?.reverse();
        });
      });
    }
  }

  @override
  void didUpdateWidget(LJImageButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    _state = widget.state;
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
    widget.forwardOrReverseValueNotifier?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Widget textChild;
    Widget imageChild;

    switch (_state) {
      case ImageButtonState.normal:
        backgroundColor = widget.backgroundColor;
        textChild = widget.textChild;
        imageChild = widget.imageChild;
        break;
      case ImageButtonState.highlight:
        backgroundColor =
            widget.highlightBackgroundColor ?? widget.backgroundColor;
        textChild = widget.highlightTextChild ?? widget.textChild;
        imageChild = widget.highlightImageChild ?? widget.imageChild;
        break;
      case ImageButtonState.selected:
        backgroundColor =
            widget.selectedBackgroundColor ?? widget.backgroundColor;
        textChild = widget.selectedTextChild ?? widget.textChild;
        imageChild = widget.selectedImageChild ?? widget.imageChild;
        break;
      case ImageButtonState.disable:
        backgroundColor =
            widget.disableBackgroundColor ?? widget.backgroundColor;
        textChild = widget.disableImageChild ?? widget.textChild;
        imageChild = widget.disableImageChild ?? widget.imageChild;
        break;
    }

    if (_animationController != null) {
      imageChild = RotationTransition(
        turns: _animation!,
        child: imageChild,
      );
    }

    CrossAxisAlignment crossAxisAlignment;
    switch (widget.imageTextAlign) {
      case ImageTextAlign.centerLeft:
        crossAxisAlignment = CrossAxisAlignment.start;
        break;
      case ImageTextAlign.center:
        crossAxisAlignment = CrossAxisAlignment.center;
        break;
      case ImageTextAlign.centerRight:
        crossAxisAlignment = CrossAxisAlignment.end;
        break;
    }

    Widget current;
    switch (widget.position) {
      case ImageButtonPosition.left:
        current = Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: crossAxisAlignment,
              children: <Widget>[
                imageChild,
                Container(
                  width: widget.spaceMargin,
                ),
                textChild,
              ],
            ),
          ],
        );
        break;
      case ImageButtonPosition.up:
        current = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: crossAxisAlignment,
              children: <Widget>[
                imageChild,
                Container(
                  height: widget.spaceMargin,
                ),
                textChild
              ],
            ),
          ],
        );
        break;
      case ImageButtonPosition.right:
        current = Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: crossAxisAlignment,
              children: <Widget>[
                textChild,
                Container(
                  width: widget.spaceMargin,
                ),
                imageChild,
              ],
            ),
          ],
        );
        break;
      case ImageButtonPosition.bottom:
        current = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: crossAxisAlignment,
              children: <Widget>[
                textChild,
                Container(
                  height: widget.spaceMargin,
                ),
                imageChild,
              ],
            ),
          ],
        );
        break;
    }

    return GestureDetector(
      onTap: (widget.onTap == null || _state == ImageButtonState.disable) ? null : () {
//        _valueNotifier.value = !_valueNotifier.value;
        widget.onTap?.call();
      },
      onTapDown: widget.onTap == null || _state == ImageButtonState.disable ? null : (
          TapDownDetails details) {
        _lastState = _state;
        _state = ImageButtonState.highlight;
        setState(() {});
      },
      onTapUp: widget.onTap == null || _state == ImageButtonState.disable ? null : (
          TapUpDetails details) {
        _state = _lastState;
        setState(() {});
      },
      onTapCancel:widget.onTap == null ||  _state == ImageButtonState.disable ? null : () {
        _state = _lastState;
        setState(() {});
      },
      child: Container(
        padding: widget.padding,
        width: widget.width,
        height: widget.height,
        alignment: widget.alignment,
        decoration: widget.decoration?.copyWith(
          color: backgroundColor,
        ) ?? BoxDecoration(color: backgroundColor),
        child: current,
      ),
    );
  }
}
