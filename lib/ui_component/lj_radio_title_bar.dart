import 'package:flutter/material.dart';

class LJRadioTitleBar extends StatefulWidget {
  const LJRadioTitleBar({
    Key? key,
    required this.count,
    this.selectedIndex,
    this.itemWidth,
    this.height = 35,
    this.spacing = 10,
    this.padding,
    this.innerPadding,
    required this.color,
    required this.selectedColor,
    required this.fontColor,
    required this.selectedFontColor,
    this.fontSize = 16,
    this.radius = 4,
    this.shrinkWrap = false,
    this.canTap = true,
    required this.getTitle,
    required this.selectedTap,
  }) : super(key: key);

  final int count;
  final int? selectedIndex;
  final double? itemWidth;
  final double height;
  /// item之间的间隙
  final double spacing;
  /// bar padding
  final EdgeInsets? padding;
  /// item内的文字padding,只有itemWidth为null的时候生效
  final EdgeInsets? innerPadding;
  final Color color;
  final Color selectedColor;
  final Color fontColor;
  final Color selectedFontColor;
  final double fontSize;
  final double radius;
  final bool shrinkWrap;
  final bool canTap;
  final String Function(int index) getTitle;
  final Function(int index) selectedTap;

  @override
  State<LJRadioTitleBar> createState() => _LJRadioTitleBarState();
}

class _LJRadioTitleBarState extends State<LJRadioTitleBar> {
  late int _currentSelectedIndex;

  @override
  void initState() {
    super.initState();
    _currentSelectedIndex = widget.selectedIndex ?? 0;
  }

  @override
  void didUpdateWidget(covariant LJRadioTitleBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != null) {
      _currentSelectedIndex = widget.selectedIndex!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ListView.separated(
        itemCount: widget.count,
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        itemBuilder: (context, index) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (!widget.canTap) return;

              setState(() {
                _currentSelectedIndex = index;
              });
              widget.selectedTap(index);
            },
            child: Container(
              width: widget.itemWidth,
              decoration: BoxDecoration(
                color: index == _currentSelectedIndex
                    ? widget.selectedColor
                    : widget.color,
                borderRadius: BorderRadius.circular(widget.radius),
              ),
              alignment: Alignment.center,
              padding: widget.itemWidth == null
                  ? widget.innerPadding ?? const EdgeInsets.symmetric(horizontal: 17)
                  : null,
              child: Text(
                widget.getTitle(index),
                style: TextStyle(
                  color: index == _currentSelectedIndex
                      ? widget.selectedFontColor
                      : widget.fontColor,
                  fontSize: widget.fontSize,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: widget.spacing);
        },
      ),
    );
  }
}
