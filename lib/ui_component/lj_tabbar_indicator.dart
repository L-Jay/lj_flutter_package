// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Used with [TabBar.indicator] to draw a horizontal line below the
/// selected tab.
///
/// The selected tab underline is inset from the tab's boundary by [insets].
/// The [borderSide] defines the line's color and weight.
///
/// The [TabBar.indicatorSize] property can be used to define the indicator's
/// bounds in terms of its (centered) widget with [TabBarIndicatorSize.label],
/// or the entire tab with [TabBarIndicatorSize.tab].
class CustomTabBarIndicator extends Decoration {
  /// Create an underline style selected tab indicator.
  ///
  /// The [borderSide] and [insets] arguments must not be null.
  const CustomTabBarIndicator({
    this.height = 2,
    this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
    this.insets = EdgeInsets.zero,
    this.width,
    this.isRound = false,
  })  : assert(borderSide != null),
        assert(insets != null);

  /// The color and weight of the horizontal line drawn below the selected tab.
  final BorderSide borderSide;

  /// Locates the selected tab's underline relative to the tab's boundary.
  ///
  /// The [TabBar.indicatorSize] property can be used to define the tab
  /// indicator's bounds in terms of its (centered) tab widget with
  /// [TabBarIndicatorSize.label], or the entire tab with
  /// [TabBarIndicatorSize.tab].
  final EdgeInsetsGeometry insets;

  /*高度，默认2*/
  final double height;

  /*宽度，不指定不生效*/
  final double? width;

  /*是否圆角*/
  final bool isRound;

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is CustomTabBarIndicator) {
      return CustomTabBarIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is CustomTabBarIndicator) {
      return CustomTabBarIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  _UnderlinePainter createBoxPainter([ VoidCallback? onChanged ]) {
    return _UnderlinePainter(this, isRound, onChanged!);
  }

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    assert(rect != null);
    assert(textDirection != null);
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);

    if (width != null) {
      double cw = (indicator.left + indicator.right)*0.5;
      return Rect.fromLTWH(cw - width!*0.5,
          indicator.bottom - borderSide.width, width!, borderSide.width);
    }

    return Rect.fromLTWH(
      indicator.left,
      indicator.bottom - borderSide.width,
      indicator.width,
      borderSide.width,
    );
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRect(_indicatorRectFor(rect, textDirection));
  }
}

class _UnderlinePainter extends BoxPainter {
  _UnderlinePainter(this.decoration, this.isRound, VoidCallback onChanged)
      : assert(decoration != null),
        super(onChanged);

  final CustomTabBarIndicator decoration;

  final bool isRound;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final TextDirection textDirection = configuration.textDirection!;
    final Rect indicator = decoration._indicatorRectFor(rect, textDirection).deflate(decoration.borderSide.width / 2.0);
    final Paint paint = decoration.borderSide.toPaint()..strokeCap = isRound ? StrokeCap.round : StrokeCap.square;
    canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
  }
}
