import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── 字重适配 ─────────────────────────────────────────────────────────────
// 设计稿按 iOS 原生（CoreText + SF Pro/PingFang）标定。实测在 iOS 上
// Flutter（Impeller/Skia，不走 CoreText）用相同字重数值渲染会整体偏细，
// 且中间值存在吸附（如 w100=w150、w700=w750），因此仅在 iOS 上把设计字重
// 映射为“实测等视觉”的数值；其余平台保持标准 CSS 字重：
//   - Android：实测与原生接近，不补偿；
//   - Windows/Linux：系统字体不同（Segoe/雅黑、Cantarell/Noto），不可套用；
//   - macOS：渲染情况可能与 iOS 类似但未实测，如需要应另行标定。
//
// 补偿值迭代过两版（完整数据见项目 skill：
// .trae/skills/font-weight-compare/references/ios-calibration.md）：
//   v1 严格按墨迹密度最近匹配（原生 w300≈Flutter450、w400≈600），跨度偏大，
//   视觉走查后弃用；当前采用 v2 保守版，整体只加约半档~一档：
//   200/300/350/450/600/700，bold 不补偿（与 semibold 在 iOS 同为 w700）。
//
// Flutter(iOS) 字重档位吸附规律（w100~w900 每 50 一档实测）：
//   系统字体（PingFang SC）只有 100/200/300/400/500/600 六个实体字面，
//   700 及以上靠引擎合成粗体；请求 x50 等中间值时就近匹配真实字面，
//   并不会产生平滑的中间字重 —— 有效阶梯只有整百档：
//     w150 完全 = w100
//     w250 完全 = w200
//     w350 介于 300/400，明显偏向 400（视觉≈升档）
//     w450 介于 400/500，偏向 400（视觉≈降档）
//     w550 介于 500/600，略偏 500
//     w650 完全 = w600
//     w750 完全 = w700
//     w850 完全 = w800
//   即：写 FontWeight(150/250/650/750/850) 没有意义（等于相邻整百），
//   350/450/550 也只是“略偏向某档”，取舍方向不固定、不可依赖。
//   当前 v2 中 semibold 与 bold 在 iOS 均为 w700（视觉等价），需要更粗
//   层级时可把 bold 调为 FontWeight(900)。

FontWeight get ultralight => isIOS ? const FontWeight(200) : FontWeight.w100;
FontWeight get thin => isIOS ? const FontWeight(300) : FontWeight.w200;
FontWeight get light => isIOS ? const FontWeight(350) : FontWeight.w300;
FontWeight get regular => isIOS ? const FontWeight(450) : FontWeight.w400;
FontWeight get medium => isIOS ? const FontWeight(600) : FontWeight.w500;
FontWeight get semibold => isIOS ? const FontWeight(700) : FontWeight.w600;
FontWeight get bold => FontWeight.bold;

typedef ObjectCallback<T> = void Function(T value);
typedef BoolCallback = void Function(bool value);

typedef ObjectCallbackResultN<T, N> = N Function(T value);
typedef CallbackResultN<N> = N Function();

bool get isAndroid {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android;
}

bool get isIOS {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.iOS;
}

Container quickContainer({
  double? width,
  double? height,
  AlignmentGeometry? alignment = Alignment.center,
  Color? color,
  String? backgroundImage,
  EdgeInsets? margin,
  EdgeInsets? padding,
  Widget? child,
  double? circular,
  BoxShadow? boxShadow,
  List<Color>? gradientColors,
  List<AlignmentGeometry> gradientAlign = const [
    Alignment.centerLeft,
    Alignment.centerRight,
  ],
  Color? borderColor,
  double borderWidth = 0,
  Clip clipBehavior = Clip.hardEdge,
}) {
  return Container(
    width: width,
    height: height,
    margin: margin,
    padding: padding,
    alignment: alignment,
    clipBehavior: clipBehavior,
    decoration: BoxDecoration(
      color: color,
      image: backgroundImage == null
          ? null
          : DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(backgroundImage),
            ),
      borderRadius: circular == null ? null : BorderRadius.circular(circular),
      boxShadow: boxShadow != null ? [boxShadow] : null,
      gradient: gradientColors != null
          ? LinearGradient(
              begin: gradientAlign.first,
              end: gradientAlign.last,
              colors: gradientColors,
            )
          : null,
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
    ),
    child: child,
  );
}

Text quickText(
  String text,
  double size,
  Color color, [
  FontWeight? fontWeight, //默认 regular；设计按 iOS 标定，iOS 上经字重适配补偿
  TextOverflow? overflow,
  String? fontFamily,
]) {
  return Text(
    text,
    overflow: overflow,
    maxLines: overflow == null ? null : 1,
    style: TextStyle(
      fontSize: size,
      color: color,
      fontFamily: fontFamily,
      fontWeight: fontWeight ?? regular,
    ),
  );
}

TextStyle textStyle(double size, Color color, [FontWeight? fontWeight]) {
  return TextStyle(
    fontSize: size,
    color: color,
    fontWeight: fontWeight ?? regular,
  );
}

ButtonStyle buttonStyle(double fontSize, Color textColor,
    {Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 0,
    FontWeight? fontWeight,
    shape}) {
  return ButtonStyle(
    textStyle: WidgetStateProperty.all(
        TextStyle(fontSize: fontSize, fontWeight: fontWeight)),
    foregroundColor: WidgetStateProperty.all(textColor),
    backgroundColor: WidgetStateProperty.all(backgroundColor),
    side: borderColor != null
        ? WidgetStateProperty.all(
            BorderSide(color: borderColor, width: borderWidth))
        : null,
    shape: WidgetStateProperty.all(shape ?? const StadiumBorder()),
  );
}

RichText quickRichText(
  List<String> strings,
  List<TextStyle> textStyles,
) {
  if (strings.length != textStyles.length) {
    return RichText(text: const TextSpan());
  }

  return RichText(
    text: TextSpan(
      children: List.generate(
        strings.length,
        (index) {
          return TextSpan(text: strings[index], style: textStyles[index]);
        },
      ),
    ),
  );
}

RichText quickRichTextTap(
  double fontSize,
  List<String> strings,
  List<Color> textColors,
  List<VoidCallback?> tapCallback,
) {
  if (strings.length != textColors.length) {
    return RichText(text: const TextSpan());
  }

  return RichText(
    text: TextSpan(
      children: List.generate(
        strings.length,
        (index) {
          return TextSpan(
            text: strings[index],
            style: TextStyle(
              fontSize: fontSize,
              color: textColors[index],
            ),
            recognizer: tapCallback[index] != null
                ? (TapGestureRecognizer()..onTap = tapCallback[index])
                : null,
          );
        },
      ),
    ),
  );
}

Widget quickGradientText(
  String text,
  List<Color> colors,
  double fontSize, {
  List<AlignmentGeometry> gradientAlign = const [
    Alignment.centerLeft,
    Alignment.centerRight,
  ],
  FontWeight? fontWeight,
}) {
  return ShaderMask(
    shaderCallback: (Rect bounds) {
      return LinearGradient(
        colors: colors,
        tileMode: TileMode.mirror,
        begin: gradientAlign.first,
        end: gradientAlign.last,
      ).createShader(bounds);
    },
    blendMode: BlendMode.srcATop,
    child: quickText(text, fontSize, Colors.white, fontWeight ?? regular),
  );
}

DecorationImage quickBgImage(String image, {BoxFit boxFit = BoxFit.fill}) {
  return DecorationImage(fit: boxFit, image: AssetImage(image));
}

Color randomColor() {
  return Color.fromARGB(255, Random().nextInt(256) + 0,
      Random().nextInt(256) + 0, Random().nextInt(256) + 0);
}

Future<int?> showActionSheet(
  BuildContext context,
  List<String> actionTitles, {
  String? title,
  String? message,
  String cancelTitle = '取消',
}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (context) {
      return CupertinoActionSheet(
        title: title == null ? null : Text(title),
        message: message == null ? null : Text(message),
        actions: actionTitles
            .map(
              (e) => CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context, actionTitles.indexOf(e));
                },
                isDefaultAction: true,
                child: Text(e),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          child: Text(cancelTitle),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    },
  );
}

Future<T> completer<T>(void Function(Completer<T> completer) body) {
  Completer<T> completer = Completer();

  body(completer);

  return completer.future;
}

String countDownTime(nowTime, endTime) {
  var surplus = endTime.difference(nowTime);
  int day = (surplus.inSeconds ~/ 3600) ~/ 24;
  int hour = (surplus.inSeconds ~/ 3600) % 24;
  int minute = surplus.inSeconds % 3600 ~/ 60;
  int second = surplus.inSeconds % 60;

  var str = '';
  if (day > 0) {
    str = '$day天';
  }
  if (hour > 0 || (day > 0 && hour == 0)) {
    str = '$str$hour小时';
  }
  str = '$str$minute分钟';
  str = '$str$second分钟';

  return str;
}

class NoChineseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(newValue.text)) {
      return oldValue;
    }
    return newValue;
  }
}

int fibonacci(int index) {
  if (index < 0) {
    throw ArgumentError('Index must be non-negative');
  }
  if (index == 0) return 0;
  if (index == 1) return 1;

  int a = 0;
  int b = 1;
  for (int i = 2; i <= index; i++) {
    int c = a + b;
    a = b;
    b = c;
  }
  return b;
}
