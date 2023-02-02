import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

class LJTileAreaView extends StatefulWidget {
  const LJTileAreaView({
    Key? key,
    required this.count,
    required this.crossAxisCount,
    required this.itemHeight,
    this.imageSize,
    this.fontSize = 14,
    required this.getImageUrl,
    required this.getTitle,
    required this.clickCallback,
  }) : super(key: key);

  final int count;
  final int crossAxisCount;
  final double itemHeight;
  final double? imageSize;
  final double fontSize;
  final String Function(int index) getImageUrl;
  final String Function(int index) getTitle;
  final Function(int index) clickCallback;

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
        color: Colors.white,
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

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        widget.clickCallback(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imgUrl.contains('assets')) Image.asset(imgUrl),
          if (!imgUrl.contains('assets'))
            LJNetworkImage(
              url: imgUrl,
              width: widget.imageSize,
              height: widget.imageSize,
            ),
          const SizedBox(height: 10),
          Text(
            widget.getTitle(index),
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
