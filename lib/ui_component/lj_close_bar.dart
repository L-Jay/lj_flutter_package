import 'package:flutter/material.dart';

class CloseBar extends StatelessWidget {
  final double height;
  final Color? color;
  final Widget title;
  final Color closeColor;
  final VoidCallback onClose;

  const CloseBar({
    super.key,
    this.height = 60,
    this.color,
    required this.title,
    required this.closeColor,
    required this.onClose,
  });

  CloseBar.title({
    Key? key,
    required String title,
    required TextStyle style,
    double height = 60,
    Color? color,
    required Color closeColor,
    required VoidCallback onClose,
  }) : this(
          key: key,
          height: height,
          color: color,
          title: Text(title, style: style),
          closeColor: closeColor,
          onClose: onClose,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: color,
      child: Stack(
        alignment: Alignment.center,
        children: [
          title,
          Positioned(
            right: 10,
            child: IconButton(
              onPressed: onClose,
              icon: Icon(
                Icons.close,
                color: closeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}