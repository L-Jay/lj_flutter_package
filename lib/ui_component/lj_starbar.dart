import 'package:flutter/material.dart';

class LJStarBar extends StatefulWidget {
  final int level;
  final int total;
  final String selectedImage;
  final String? defaultImage;
  final bool canSelect;
  final double margin;
  final double? width;
  final double? height;
  final Function(int level)? callback;

  const LJStarBar({
    Key? key,
    required this.level,
    required this.selectedImage,
    this.defaultImage,
    this.canSelect = false,
    this.margin = 10,
    this.width,
    this.height,
    this.total = 5,
    this.callback,
  }) : super(key: key);

  @override
  State<LJStarBar> createState() => _LJStarBarState();
}

class _LJStarBarState extends State<LJStarBar> {
  late int _currentLevel;

  @override
  void initState() {
    super.initState();

    _currentLevel = widget.level;
  }

  @override
  void didUpdateWidget(LJStarBar oldWidget) {
    _currentLevel = widget.level;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = List.generate(
      widget.total,
      (index) => _imageItem(
          index < _currentLevel ? widget.selectedImage : widget.defaultImage,
          index),
    ).toList();

    return Row(
      children: stars,
    );
  }

  Widget _imageItem(String? name, int index) {
    return Padding(
      padding: EdgeInsets.only(
          right: name == null ||
                  (widget.defaultImage == null && _currentLevel == index + 1)
              ? 0
              : widget.margin),
      child: name == null
          ? null
          : GestureDetector(
              onTap: () {
                if (widget.canSelect) {
                  setState(() {
                    _currentLevel = index + 1;
                    if (widget.callback != null) {
                      widget.callback!(_currentLevel);
                    }
                  });
                }
              },
              child: Image.asset(
                name,
                width: widget.width,
                height: widget.height,
                fit: BoxFit.fill,
              ),
            ),
    );
  }
}
