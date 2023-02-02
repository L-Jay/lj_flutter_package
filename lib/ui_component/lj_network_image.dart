import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class LJNetworkImage extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  final String? url;
  final Widget? placeholderWidget;
  final Widget? errorWidget;

  final BoxFit fit;

  const LJNetworkImage({
    Key? key,
    this.width,
    this.height,
    required this.url,
    this.placeholderWidget,
    this.errorWidget,
    this.radius = 0,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  static Widget defaultPlaceholderWidget = Container(
    color: const Color(0xFFF5F6F6),
  );

  static Widget defaultErrorWidget = Container(
    color: const Color(0xFFF5F6F6),
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url?.isNotEmpty == true
          ? CachedNetworkImage(
              imageUrl: url!,
              fit: fit,
              width: width,
              height: height,
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
  }
}
