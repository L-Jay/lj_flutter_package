import 'package:flutter/material.dart';

/// 图片位置
enum ButtonImagePosition { left, top, right, bottom }

/// 图文对齐方式（仅垂直布局<图片在上/下>时生效，控制水平对齐）
enum ButtonImageTextAlign { centerLeft, center, centerRight }

/// 渐变方向
enum ButtonGradientDirection { leftToRight, rightToLeft, topToBottom, bottomToTop }

class LJImageButton extends StatefulWidget {
  // ==================== 文字相关 ====================
  final String text;
  final TextStyle? textStyle;
  final int maxLines;
  final TextOverflow overflow;
  final Widget? textWidget;

  // ==================== 图片相关 ====================
  final String? image;
  final double? imageWidth;
  final double? imageHeight;
  final Widget? imageWidget;
  final double spaceMargin;
  final ButtonImagePosition position;
  final ButtonImageTextAlign align;

  // ==================== 状态 ====================
  final bool selected;
  final VoidCallback? onPressed;

  // ==================== 纯色背景 ====================
  final Color? backgroundColor;
  final Color? highlightBackgroundColor;
  final Color? selectedBackgroundColor;
  final Color? disableBackgroundColor;

  // ==================== 渐变背景（优先级高于纯色） ====================
  /// 普通状态渐变颜色数组（长度≥2才生效）
  final List<Color>? gradientColors;

  /// 按下状态渐变颜色数组
  final List<Color>? highlightGradientColors;

  /// 选中状态渐变颜色数组
  final List<Color>? selectedGradientColors;

  /// 禁用状态渐变颜色数组
  final List<Color>? disableGradientColors;

  /// 渐变方向，默认从左到右
  final ButtonGradientDirection gradientDirection;

  // ==================== 文字颜色 ====================
  final Color? foregroundColor;
  final Color? disableForegroundColor;

  // ==================== 边框 ====================
  final BorderSide? borderSide;
  final Color? disableBorderColor;

  // ==================== 样式 ====================
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool shrinkWrap;
  final bool disableInkWell;

  const LJImageButton({
    super.key,
    this.text = '',
    this.textStyle,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textWidget,
    this.image,
    this.imageWidth,
    this.imageHeight,
    this.imageWidget,
    this.spaceMargin = 8,
    this.position = ButtonImagePosition.left,
    this.align = ButtonImageTextAlign.center,
    this.selected = false,
    this.onPressed,
    this.backgroundColor,
    this.highlightBackgroundColor,
    this.selectedBackgroundColor,
    this.disableBackgroundColor,
    this.gradientColors,
    this.highlightGradientColors,
    this.selectedGradientColors,
    this.disableGradientColors,
    this.gradientDirection = ButtonGradientDirection.leftToRight,
    this.foregroundColor,
    this.disableForegroundColor,
    this.borderSide,
    this.disableBorderColor,
    this.borderRadius = 12,
    this.padding,
    this.width,
    this.height,
    this.shrinkWrap = false,
    this.disableInkWell = true,
  });

  @override
  State<LJImageButton> createState() => _LJImageButtonState();
}

class _LJImageButtonState extends State<LJImageButton> {
  bool _isPressed = false;
  bool get _isDisabled => widget.onPressed == null;

  /// 是否启用渐变模式
  bool get _hasGradient =>
      widget.gradientColors != null && widget.gradientColors!.length >= 2;

  /// 方向枚举转 Alignment
  _GradientConfig _getGradientConfig() {
    switch (widget.gradientDirection) {
      case ButtonGradientDirection.leftToRight:
        return _GradientConfig(begin: Alignment.centerLeft, end: Alignment.centerRight);
      case ButtonGradientDirection.rightToLeft:
        return _GradientConfig(begin: Alignment.centerRight, end: Alignment.centerLeft);
      case ButtonGradientDirection.topToBottom:
        return _GradientConfig(begin: Alignment.topCenter, end: Alignment.bottomCenter);
      case ButtonGradientDirection.bottomToTop:
        return _GradientConfig(begin: Alignment.bottomCenter, end: Alignment.topCenter);
    }
  }

  /// 获取当前状态对应的渐变颜色
  List<Color>? _getCurrentGradientColors() {
    if (_isDisabled) {
      return widget.disableGradientColors ?? widget.gradientColors;
    }
    if (widget.selected) {
      return widget.selectedGradientColors ?? widget.gradientColors;
    }
    return widget.gradientColors;
  }

  /// 构建渐变对象
  Gradient? _buildGradient() {
    final colors = _getCurrentGradientColors();
    if (colors == null || colors.length < 2) return null;

    final config = _getGradientConfig();
    return LinearGradient(
      begin: config.begin,
      end: config.end,
      colors: colors,
    );
  }

  /// 构建图片组件：优先级 imageWidget > image
  Widget? _buildImageWidget() {
    Widget? imageWidget;

    if (widget.imageWidget != null) {
      imageWidget = widget.imageWidget!;
    } else if (widget.image != null && widget.image!.isNotEmpty) {
      imageWidget = Image.asset(
        widget.image!,
        width: widget.imageWidth,
        height: widget.imageHeight,
        fit: BoxFit.contain,
      );
    }

    if (imageWidget == null) return null;

    if (_isDisabled) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  CrossAxisAlignment _getCrossAxisAlignment() {
    switch (widget.align) {
      case ButtonImageTextAlign.centerLeft:
        return CrossAxisAlignment.start;
      case ButtonImageTextAlign.center:
        return CrossAxisAlignment.center;
      case ButtonImageTextAlign.centerRight:
        return CrossAxisAlignment.end;
    }
  }

  /// 构建文字侧组件
  Widget _buildTextSideWidget() {
    if (widget.textWidget != null) {
      return widget.textWidget!;
    }

    return Text(
      widget.text,
      style: widget.textStyle,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: TextAlign.center,
    );
  }

  /// 构建核心图文内容
  Widget _buildContentChild() {
    final imageWidget = _buildImageWidget();
    final textSideWidget = _buildTextSideWidget();

    if (imageWidget == null) {
      return textSideWidget;
    }

    final bool isHorizontal =
        widget.position == ButtonImagePosition.left ||
            widget.position == ButtonImagePosition.right;
    final crossAlign = _getCrossAxisAlignment();

    final List<Widget> children = [];

    if (widget.position == ButtonImagePosition.left ||
        widget.position == ButtonImagePosition.top) {
      children.add(imageWidget);
      children.add(SizedBox(
        width: isHorizontal ? widget.spaceMargin : 0,
        height: isHorizontal ? 0 : widget.spaceMargin,
      ));
      children.add(textSideWidget);
    } else {
      children.add(textSideWidget);
      children.add(SizedBox(
        width: isHorizontal ? widget.spaceMargin : 0,
        height: isHorizontal ? 0 : widget.spaceMargin,
      ));
      children.add(imageWidget);
    }

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAlign,
        children: children,
      );
    }
  }

  /// 构建渐变背景子元素
  Widget _buildGradientChild() {
    final gradient = _buildGradient();
    final usePressOpacity =
        _isPressed && widget.highlightGradientColors == null && gradient != null;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: usePressOpacity ? 0.85 : 1.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: widget.highlightGradientColors != null && _isPressed
                    ? LinearGradient(
                  begin: _getGradientConfig().begin,
                  end: _getGradientConfig().end,
                  colors: widget.highlightGradientColors!,
                )
                    : gradient,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
          ),
        ),
        Padding(
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _buildContentChild(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectivePadding = _hasGradient
        ? EdgeInsets.zero
        : widget.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return GestureDetector(
      onTapDown: _isDisabled
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: _isDisabled
          ? null
          : (_) => setState(() => _isPressed = false),
      onTapCancel: _isDisabled
          ? null
          : () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: FilledButton(
          onPressed: widget.onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (_hasGradient) return Colors.transparent;

              if (states.contains(WidgetState.disabled)) {
                return widget.disableBackgroundColor ?? Colors.transparent;
              }
              if (states.contains(WidgetState.pressed)) {
                if (widget.highlightBackgroundColor != null) {
                  return widget.highlightBackgroundColor;
                }
                final baseColor = widget.selected
                    ? widget.selectedBackgroundColor
                    : widget.backgroundColor;
                return baseColor?.withValues(alpha: 0.85) ?? Colors.transparent;
              }
              if (widget.selected) {
                return widget.selectedBackgroundColor ?? Colors.transparent;
              }
              return widget.backgroundColor ?? Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return widget.disableForegroundColor ?? Colors.grey.shade600;
              }
              return widget.foregroundColor;
            }),
            overlayColor: widget.disableInkWell
                ? WidgetStateProperty.all(Colors.transparent)
                : null,
            shape: WidgetStateProperty.resolveWith((states) {
              final isDisabled = states.contains(WidgetState.disabled);
              BorderSide? side = widget.borderSide;
              if (isDisabled && widget.borderSide != null) {
                side = widget.borderSide!.copyWith(
                  color: widget.disableBorderColor ?? Colors.grey.shade400,
                );
              }
              return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                side: side ?? BorderSide.none,
              );
            }),
            padding: WidgetStateProperty.all(effectivePadding),
            minimumSize: WidgetStateProperty.all(
              widget.shrinkWrap ? Size.zero : const Size(44, 36),
            ),
            tapTargetSize: widget.shrinkWrap
                ? MaterialTapTargetSize.shrinkWrap
                : MaterialTapTargetSize.padded,
          ),
          child: _hasGradient
              ? _buildGradientChild()
              : _buildContentChild(),
        ),
      ),
    );
  }
}

/// 渐变配置辅助类
class _GradientConfig {
  final Alignment begin;
  final Alignment end;
  _GradientConfig({required this.begin, required this.end});
}
