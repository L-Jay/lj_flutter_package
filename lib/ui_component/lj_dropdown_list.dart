import 'package:flutter/material.dart';

enum LJDropdownPosition {
  middle,
  right,
}

class LJDropdownList extends StatefulWidget {
  /// 不传显示3个点
  final Widget? targetWidget;

  /// 3个点颜色
  final Color? dotColor;

  /// 菜单是否与targetWidget等宽
  final bool equalWidth;

  /// 与equalWidth同时指定,优先使用itemWidth
  final double? itemWidth;

  /// 只有在在指定itemWidth的时候生效
  final LJDropdownPosition? position;

  final Color? backgroundColor;
  final Color? shadowColor;
  final double? elevation;
  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;

  final int length;
  final Widget Function(int index) itemBuilder;
  final void Function(int index) onSelected;

  const LJDropdownList({
    super.key,
    this.targetWidget,
    this.dotColor,
    this.equalWidth = true,
    this.itemWidth,
    this.position,
    this.backgroundColor,
    this.shadowColor,
    this.elevation,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    required this.length,
    required this.itemBuilder,
    required this.onSelected,
  });

  @override
  State<LJDropdownList> createState() => _LJDropdownListState();
}

class _LJDropdownListState extends State<LJDropdownList> {
  final GlobalKey _globalKey = GlobalKey();
  late bool _equalWidth;
  BoxConstraints? _constraints;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();

    _equalWidth = widget.equalWidth && widget.targetWidget != null;

    if (_equalWidth && widget.itemWidth == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        var width = _globalKey.currentContext?.size?.width ?? 0;
        if (width > 0) {
          _constraints = BoxConstraints(minWidth: width, maxWidth: width);
          setState(() {});
        }
      });
    } else if (widget.itemWidth != null) {
      _constraints = BoxConstraints(
        minWidth: widget.itemWidth!,
        maxWidth: widget.itemWidth!,
      );

      if (widget.position != null) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          var width = _globalKey.currentContext?.size?.width ?? 0;
          if (width > 0) {
            var dx = 0.0;
            if (widget.position == LJDropdownPosition.middle) {
              dx = (width - widget.itemWidth!) * 0.5;
            } else if (widget.position == LJDropdownPosition.right) {
              dx = width - widget.itemWidth!;
            }

            _offset = Offset(dx, 0);
            setState(() {});
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showShape = widget.borderRadius != null || widget.borderWidth != null;

    return PopupMenuButton(
      key: _globalKey,
      color: widget.backgroundColor,
      offset: _offset,
      iconColor: widget.dotColor,
      position: PopupMenuPosition.under,
      menuPadding: EdgeInsets.zero,
      constraints: _constraints,
      shadowColor: widget.shadowColor,
      elevation: widget.elevation,
      padding: EdgeInsets.zero,
      onSelected: widget.onSelected,
      shape: showShape
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: widget.borderWidth != null
                  ? BorderSide(
                      width: widget.borderWidth ?? 1,
                      color: widget.borderColor ?? Colors.black,
                      style: BorderStyle.solid,
                    )
                  : BorderSide.none,
            )
          : null,
      itemBuilder: (BuildContext context) {
        return List.generate(widget.length, (index) {
          return PopupMenuItem(
            value: index,
            child: widget.itemBuilder(index),
          );
        }).toList();
      },
      child: widget.targetWidget,
    );
  }
}
