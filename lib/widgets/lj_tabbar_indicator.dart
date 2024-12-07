import 'package:flutter/material.dart';

class LJTabBarIndicator extends Decoration {
  final Color color;
  final Size size;
  final double radius;

  const LJTabBarIndicator({
    required this.color,
    this.size = const Size(20, 3),
    this.radius = 1.5,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _LJTabBarIndicatorPainter(this, color, onChanged, size, radius);
  }
}

class _LJTabBarIndicatorPainter extends BoxPainter {
  final LJTabBarIndicator decoration;
  final Color color;
  final Size size;
  final double radius;

  _LJTabBarIndicatorPainter(
    this.decoration,
    this.color,
    VoidCallback? onChanged,
    this.size,
    this.radius,
  ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final canvasSize = configuration.size!;
    final newOffset = Offset(
      offset.dx + (canvasSize.width - size.width) / 2,
      canvasSize.height - size.height,
    );
    final Rect rect = newOffset & size;
    final Paint paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }
}
