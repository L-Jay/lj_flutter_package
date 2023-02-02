import 'package:flutter/material.dart';

class LJHalfCornerClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.height, 0);
    path.arcToPoint(Offset(size.height, size.height), radius: Radius.circular(size.height*0.5), clockwise: false);
    path.lineTo(size.width-size.height, size.height);
    path.arcToPoint(Offset(size.width-size.height, 0), radius: Radius.circular(size.height*0.5), clockwise: false);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}