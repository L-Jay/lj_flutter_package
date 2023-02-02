import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety_flutter3/flutter_swiper_null_safety_flutter3.dart';

import '../utils/lj_define.dart';
import 'lj_network_image.dart';

class LJSwiper<T> extends StatefulWidget {
  final List<T> viewModels;
  final String Function(T t) getImgUrl;
  final void Function(T t)? onTap;

  final EdgeInsets padding;
  final double connerRadius;
  final double aspectRatio;
  final Color? backgroundColor;
  final BoxShadow? shadow;
  final int imageType;
  final BoxFit fit;
  final bool? autoplay;
  final bool? loop;
  final SwiperPlugin pagination;

  const LJSwiper({
    Key? key,
    required this.viewModels,
    required this.getImgUrl,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.connerRadius = 0,
    this.aspectRatio = 16 / 9,
    this.backgroundColor,
    this.fit = BoxFit.cover,
    this.imageType = 0,
    this.shadow,
    this.autoplay,
    this.loop,
    this.pagination = const LJSwiperDotPagination(),
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LJSwiperState<T>();
}

class _LJSwiperState<T> extends State<LJSwiper<T>> {
  List<T> get list => widget.viewModels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.connerRadius),
            boxShadow: widget.shadow != null
                ? [
                    widget.shadow!,
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.connerRadius),
            child: Swiper(
              autoplay: widget.autoplay ?? widget.viewModels.length > 1,
              loop: widget.loop ?? widget.viewModels.length > 1,
              itemCount: widget.viewModels.length,
              itemBuilder: (BuildContext context, int index) {
                return widget.imageType == 1
                    ? Image.asset(
                        widget.getImgUrl(widget.viewModels[index]),
                        fit: widget.fit,
                      )
                    : LJNetworkImage(
                        url: widget.getImgUrl(widget.viewModels[index]),
                        fit: widget.fit,
                      );
              },
              onTap: (index) {
                widget.onTap?.call(widget.viewModels[index]);
              },
              pagination:
                  widget.viewModels.length > 1 ? widget.pagination : null,
            ),
          ),
        ),
      ),
    );
  }
}

class LJSwiperDotPagination extends SwiperPlugin {
  final Alignment alignment;
  final EdgeInsets margin;
  final double width;
  final double activeWidth;
  final double height;
  final double activeHeight;
  final Color color;
  final Color activeColor;
  final double space;

  const LJSwiperDotPagination({
    this.alignment = const Alignment(1, 1),
    this.margin = const EdgeInsets.only(right: 20, bottom: 20),
    this.width = 5,
    this.activeWidth = 15,
    this.height = 5,
    this.activeHeight = 5,
    this.space = 4,
    this.color = Colors.white,
    this.activeColor = Colors.white,
  });

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: margin,
        child: LJSwiperDot(
          config: config,
          width: width,
          activeWidth: activeWidth,
          height: height,
          activeHeight: activeHeight,
          color: color,
          activeColor: activeColor,
          space: space,
        ),
      ),
    );
  }
}

class LJSwiperDot extends StatefulWidget {
  final SwiperPluginConfig config;
  final double width;
  final double activeWidth;
  final double height;
  final double activeHeight;
  final Color color;
  final Color activeColor;
  final double space;

  const LJSwiperDot({
    Key? key,
    required this.config,
    required this.width,
    required this.activeWidth,
    required this.height,
    required this.activeHeight,
    required this.space,
    required this.color,
    required this.activeColor,
  }) : super(key: key);

  @override
  State<LJSwiperDot> createState() => _LJSwiperDotState();
}

class _LJSwiperDotState extends State<LJSwiperDot> {
  double _page = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.config.pageController?.addListener(() {
        setState(() {
          _page = widget.config.pageController?.page as double;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dots = [];

    double ratioWidth = widget.activeWidth - widget.width;
    double ratioHeight = widget.activeHeight - widget.height;

    int itemCount = widget.config.itemCount;
    int floor = _page.floor();
    int ceil = _page.ceil();
    int preIndex = floor % itemCount;
    int nextIndex = ceil % itemCount;
    double prePercent = _page - preIndex;
    double nextPercent = 1 - prePercent;

    dots = List.generate(
      widget.config.itemCount,
      (index) {
        double currentWidth;
        double currentHeight;
        Color currentColor;

        if (index == preIndex) {
          currentWidth = widget.width + (ratioWidth * nextPercent);

          if (ratioHeight == 0) {
            currentHeight = widget.height;
          }else {
            currentHeight = widget.height + (ratioHeight *nextPercent);
          }

          if (widget.color == widget.activeColor) {
            currentColor = widget.color;
          }else {
            currentColor = Color.lerp(widget.color, widget.activeColor, nextPercent) ?? widget.color;
          }
        } else if (index == nextIndex) {
          currentWidth = widget.width + (ratioWidth * prePercent);

          if (ratioHeight == 0) {
            currentHeight = widget.height;
          }else {
            currentHeight = widget.height + (ratioHeight *prePercent);
          }

          if (widget.color == widget.activeColor) {
            currentColor = widget.color;
          }else {
            currentColor = Color.lerp(widget.color, widget.activeColor, prePercent) ?? widget.activeColor;
          }
        } else {
          currentWidth = widget.width;
          currentHeight = widget.height;
          currentColor = widget.color;
        }

        return Container(
          width: currentWidth,
          height: currentHeight,
          margin: EdgeInsets.only(right: widget.space),
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(currentHeight * 0.5),
          ),
        );
      },
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: dots,
    );
  }
}

class LJSwiperTextPagination extends SwiperPlugin {
  final Alignment alignment;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color backgroundColor;
  final TextStyle style;
  final TextStyle activeStyle;
  final double circular;

  const LJSwiperTextPagination({
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.only(right: 20, bottom: 20),
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    this.circular = 10,
    this.backgroundColor = Colors.black45,
    this.style = const TextStyle(fontSize: 12, color: Colors.white),
    this.activeStyle = const TextStyle(fontSize: 12, color: Colors.white),
  });

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    return Align(
      alignment: alignment,
      child: quickContainer(
        margin: margin,
        padding: padding,
        circular: circular,
        color: backgroundColor,
        child: quickRichText(
          [config.activeIndex.toString(), '/', config.itemCount.toString()],
          [activeStyle, style, style],
        ),
      ),
    );
  }
}
