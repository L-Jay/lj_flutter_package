import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

class LJWrapRadio extends StatefulWidget {
  final int count;
  final Widget Function(BuildContext context, int index, bool selected)
      itemBuilder;
  final Function(int index) selectedChanged;
  final int? selectedIndex;
  final double spacing;
  final double runSpacing;

  const LJWrapRadio({
    super.key,
    required this.count,
    required this.itemBuilder,
    required this.selectedChanged,
    this.spacing = 10,
    this.runSpacing = 5,
    this.selectedIndex,
  });

  @override
  State<LJWrapRadio> createState() => _LJWrapRadioState();
}

class _LJWrapRadioState extends State<LJWrapRadio> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant LJWrapRadio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != null) {
      _selectedIndex = widget.selectedIndex!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: List.generate(widget.count, (index) {
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
          child: widget.itemBuilder(context, index, index == _selectedIndex),
        );
      }).toList(),
    );
  }
}

class LJWrapRadioTitle extends StatelessWidget {
  final List<String> titles;
  final Color? borderColor;
  final Color? activeBorderColor;
  final Color? backgroundColor;
  final Color? activeBackgroundColor;
  final TextStyle? style;
  final TextStyle? activeStyle;
  final Function(int index) selectedChanged;
  final int? selectedIndex;

  const LJWrapRadioTitle({
    super.key,
    required this.titles,
    required this.selectedChanged,
    this.selectedIndex,
    this.borderColor,
    this.activeBorderColor,
    this.backgroundColor,
    this.activeBackgroundColor,
    this.style,
    this.activeStyle,
  });

  @override
  Widget build(BuildContext context) {
    return LJWrapRadio(
      count: titles.length,
      itemBuilder: (context, index, selected) => _buildItem(index, selected),
      selectedChanged: selectedChanged,
      selectedIndex: selectedIndex,
    );
  }

  Widget _buildItem(int index, bool selected) {
    return quickContainer(
      alignment: null,
      circular: style?.fontSize ?? 14,
      color: selected ? activeBackgroundColor : backgroundColor,
      borderColor: selected ? activeBorderColor : borderColor,
      borderWidth: 1,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      child: Text(titles[index], style: selected ? activeStyle : style),
    );
  }
}

class LJWrapRadioCheckbox extends StatelessWidget {
  final List<String> titles;

  /// 指定后文字不使用color/activeColor,跟随选择变化
  final Color? fontColor;
  final double? fontSize;
  final String? iconName;
  final String? activeIconName;
  final Color? color;
  final Color? activeColor;
  final Function(int index) selectedChanged;
  final int? selectedIndex;

  const LJWrapRadioCheckbox({
    super.key,
    required this.titles,
    required this.selectedChanged,
    this.iconName,
    this.activeIconName,
    this.fontSize,
    this.fontColor,
    this.color,
    this.activeColor,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LJWrapRadio(
      count: titles.length,
      itemBuilder: (context, index, selected) => _buildItem(index, selected),
      selectedChanged: selectedChanged,
      selectedIndex: selectedIndex,
    );
  }

  Widget _buildItem(int index, bool selected) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconName != null && activeIconName != null)
          Image.asset(selected ? activeIconName! : iconName!),
        if (iconName == null || activeIconName == null)
          Icon(
            selected ? Icons.check_circle : Icons.check_circle_outline,
            color: selected ? activeColor : color,
            size: min(fontSize ?? 16, 20),
          ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            titles[index],
            softWrap: true,
            style: TextStyle(
              fontSize: fontSize,
              color: fontColor ?? (selected ? activeColor : color),
            ),
          ),
        ),
      ],
    );
  }
}
