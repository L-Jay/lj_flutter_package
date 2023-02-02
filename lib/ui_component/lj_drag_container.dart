import 'package:flutter/material.dart';
import '../utils/lj_define.dart';

enum LJDragAdsorption {
  onlyTop,
  onlyBottom,
  onlyLeft,
  onlyRight,
  horizontal,
  vertical,
  all,
  none,
}

class LJDragContainer extends StatefulWidget {
  final double width;
  final double height;
  final double circular;
  final Color color;

  /*初始位置*/
  final Offset offset;
  final LJDragAdsorption adsorption;
  final GestureTapCallback? onTap;
  final Widget? child;

  /*父Widget必须是Stack*/
  const LJDragContainer({
    Key? key,
    this.width = 56,
    this.height = 56,
    this.circular = 28,
    this.color = Colors.orange,
    this.offset = const Offset(20, 20),
    this.adsorption = LJDragAdsorption.none,
    this.onTap,
    this.child,
  }) : super(key: key);

  @override
  State<LJDragContainer> createState() => _LJDragContainerState();
}

class _LJDragContainerState extends State<LJDragContainer>
    with SingleTickerProviderStateMixin {
  late Size _parentSize;
  late double _maxX;
  late double _maxY;
  late Offset _offset;

  bool _needAnimated = false;

  @override
  void initState() {
    _offset = widget.offset;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Rect? parentRect = context.findAncestorRenderObjectOfType()?.paintBounds;
      if (parentRect != null) {
        _parentSize = parentRect.size;
        _maxX = _parentSize.width - widget.width;
        _maxY = _parentSize.height - widget.height;
      } else {
        _parentSize = MediaQuery.of(context).size;
        _maxX = _parentSize.width - widget.width;
        _maxY = _parentSize.height - widget.height;
      }
    });

    super.initState();
  }

  Offset _calOffset(Offset offset, Offset nextOffset) {
    double dx = 0;
    //水平方向偏移量不能小于0不能大于屏幕最大宽度
    if (offset.dx + nextOffset.dx <= 0) {
      dx = 0;
    } else if (offset.dx + nextOffset.dx >= _maxX) {
      dx = _maxX;
    } else {
      dx = offset.dx + nextOffset.dx;
    }

    double dy = 0;
    //垂直方向偏移量不能小于0不能大于屏幕最大高度
    if (offset.dy + nextOffset.dy >= _maxY) {
      dy = _maxY;
    } else if (offset.dy + nextOffset.dy <= 0) {
      dy = 0;
    } else {
      dy = offset.dy + nextOffset.dy;
    }

    return Offset(
      dx,
      dy,
    );
  }

  void _nearestOffset() {
    _needAnimated = true;

    Offset destination = _offset;
    switch (widget.adsorption) {
      case LJDragAdsorption.none:
        break;
      case LJDragAdsorption.onlyTop:
        destination = Offset(_offset.dx, 0);
        break;
      case LJDragAdsorption.onlyBottom:
        destination = Offset(_offset.dx, _maxY);
        break;
      case LJDragAdsorption.onlyLeft:
        destination = Offset(0, _offset.dy);
        break;
      case LJDragAdsorption.onlyRight:
        destination = Offset(_maxX, _offset.dy);
        break;
      case LJDragAdsorption.horizontal:
        double x = _offset.dx + widget.width * 0.5;
        destination = x > _parentSize.width * 0.5
            ? Offset(_maxX, _offset.dy)
            : Offset(0, _offset.dy);
        break;
      case LJDragAdsorption.vertical:
        double y = _offset.dy + widget.height * 0.5;
        destination = y > _parentSize.height * 0.5
            ? Offset(_offset.dx, _maxY)
            : Offset(_offset.dx, 0);
        break;
      case LJDragAdsorption.all:
        double distanceMaxX = _parentSize.width - _offset.dx - widget.width;
        double distanceMaxY = _parentSize.height - _offset.dy - widget.height;
        List<double> temp = [
          _offset.dx,
          _offset.dy,
          distanceMaxX,
          distanceMaxY
        ];
        temp.sort();
        double minDistance = temp.first;
        if (minDistance == _offset.dx) {
          destination = Offset(0, _offset.dy);
        } else if (minDistance == distanceMaxX) {
          destination = Offset(_maxX, _offset.dy);
        } else if (minDistance == _offset.dy) {
          destination = Offset(_offset.dx, 0);
        } else if (minDistance == distanceMaxY) {
          destination = Offset(_offset.dx, _maxY);
        }
        break;
    }

    setState(() {
      _offset = destination;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: _offset.dx,
      top: _offset.dy,
      duration: Duration(milliseconds: _needAnimated ? 250 : 0),
      onEnd: () {
        _needAnimated = false;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onPanStart:  (detail) {
          _needAnimated = false;
        },
        onPanUpdate: (detail) {
          setState(() {
            _offset = _calOffset(_offset, detail.delta);
          });
        },
        onPanEnd: (detail) {
          _nearestOffset();
        },
        onPanCancel: () {
          _nearestOffset();
        },
        child: quickContainer(
          width: widget.width,
          height: widget.height,
          circular: widget.circular,
          color: widget.color,
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
