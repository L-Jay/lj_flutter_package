
import 'package:flutter/material.dart';

class LJSliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  LJSliverTabBarDelegate(
    this.tabBar, {
    this.height = 44.0,
    this.color = Colors.white,
  });

  final Widget tabBar;
  final double height;
  final Color color;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: height,
      color: color,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(LJSliverTabBarDelegate oldDelegate) {
    return false;
  }
}