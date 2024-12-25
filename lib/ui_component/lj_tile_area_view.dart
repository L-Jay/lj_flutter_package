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

  /// 字体style,指定getTitleWidget此属性不生效
  final TextStyle textStyle;
  final String Function(int index)? getImageUrl;
  final Widget Function(int index)? getImageWidget;
  final String Function(int index)? getTitle;
  final Widget Function(int index)? getTitleWidget;
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
      color: Color(0xFF333333),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    this.getImageUrl,
    this.getImageWidget,
    this.getTitle,
    this.getTitleWidget,
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
    Widget imageWidget = const SizedBox();

    if (widget.getImageWidget != null) {
      imageWidget = widget.getImageWidget!(index);
    } else if (widget.getImageUrl != null) {
      String imgUrl = widget.getImageUrl!(index);
      if (imgUrl.contains('assets')) {
        imageWidget = Image.asset(imgUrl);
      } else {
        imageWidget = LJNetworkImage(
          url: imgUrl,
          width: widget.imageSize,
          height: widget.imageSize,
        );
      }
    }

    Widget titleWidget = const SizedBox();

    if (widget.getTitleWidget != null) {
      titleWidget = widget.getTitleWidget!(index);
    } else if (widget.getTitle != null) {
      titleWidget = Text(widget.getTitle!(index), style: widget.textStyle);
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
          titleWidget,
        ],
      ),
    );
  }
}
