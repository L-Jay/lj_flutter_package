import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

class LJTileAreaView extends StatefulWidget {
  /// 总个数
  final int count;

  /// 每一行的个数
  final int crossAxisCount;

  /// 整个item的高度，图片加下面的文字
  final double itemHeight;

  /// 图片的大小
  final double? imageSize;

  /// 图片背景色
  final Color? imageBackgroundColor;

  /// 图片圆角
  final double? imageCornerRadius;

  /// 间距
  final double space;

  /// 组件背景
  final Color backgroundColor;

  /// 字体style
  final TextStyle textStyle;
  final String Function(int index) getImageUrl;
  final String Function(int index) getTitle;
  final Function(int index) clickCallback;

  const LJTileAreaView({
    Key? key,
    required this.count,
    required this.crossAxisCount,
    required this.itemHeight,
    this.imageSize,
    this.imageBackgroundColor,
    this.imageCornerRadius,
    this.space = 5,
    this.backgroundColor = Colors.white,
    this.textStyle = const TextStyle(
      color: const Color(0xFF333333),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    required this.getImageUrl,
    required this.getTitle,
    required this.clickCallback,
  }) : super(key: key);

  @override
  State<LJTileAreaView> createState() => _LJTileAreaViewState();
}

class _LJTileAreaViewState extends State<LJTileAreaView> {
  @override
  Widget build(BuildContext context) {
    double? width = context.findRenderObject()?.paintBounds.width;
    width ??= MediaQuery.of(context).size.width - 30;

    double itemWidth = width / widget.crossAxisCount;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.5),
        color: widget.backgroundColor,
      ),
      child: GridView.count(
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: itemWidth / widget.itemHeight,
        children: List.generate(widget.count, (index) => _buildItem(index)),
      ),
    );
  }

  Widget _buildItem(int index) {
    String imgUrl = widget.getImageUrl(index);
    Widget imageWidget;
    if (imgUrl.contains('assets')) {
      imageWidget = Image.asset(imgUrl);
    } else {
      imageWidget = LJNetworkImage(
        url: imgUrl,
        width: widget.imageSize,
        height: widget.imageSize,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        widget.clickCallback(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          quickContainer(
            width: widget.imageSize,
            height: widget.imageSize,
            color: widget.imageBackgroundColor,
            circular: widget.imageCornerRadius,
            alignment: null,
            child: imageWidget,
          ),
          SizedBox(height: widget.space),
          Text(
            widget.getTitle(index),
            style: widget.textStyle,
          ),
        ],
      ),
    );
  }
}
