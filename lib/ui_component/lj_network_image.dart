import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

class LJNetworkImage extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final double borderWidth;
  final Color? borderColor;
  final Color? color;

  final String? url;
  final Widget? placeholderWidget;
  final Widget? errorWidget;

  final BoxFit fit;

  const LJNetworkImage({
    Key? key,
    this.width,
    this.height,
    this.radius = 0,
    this.borderWidth = 0,
    this.borderColor,
    this.color,
    required this.url,
    this.placeholderWidget,
    this.errorWidget,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  static Widget defaultPlaceholderWidget = Container(color: Colors.grey.shade200);

  static Widget defaultErrorWidget = Container(color: Colors.grey.shade200);

  @override
  Widget build(BuildContext context) {
    Widget widget = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url?.isNotEmpty == true
          ? CachedNetworkImage(
              imageUrl: url!,
              fit: fit,
              width: borderWidth > 0 ? null : width,
              height: borderWidth > 0 ? null : height,
              placeholder: (context, url) {
                return placeholderWidget ?? defaultPlaceholderWidget;
              },
              errorWidget: (context, url, dynamic error) {
                return errorWidget ?? defaultErrorWidget;
              },
            )
          : SizedBox(
              width: width,
              height: height,
              child: placeholderWidget ?? defaultPlaceholderWidget,
            ),
    );

    widget = quickContainer(
      width: width,
      height: height,
      borderWidth: borderWidth,
      borderColor: borderColor,
      color: color,
      child: widget,
      alignment: null,
      circular: radius,
    );

    return widget;
  }
}
