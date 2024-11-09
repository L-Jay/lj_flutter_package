import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const FontWeight ultralight = FontWeight.w100;
const FontWeight thin = FontWeight.w200;
const FontWeight light = FontWeight.w300;
const FontWeight regular = FontWeight.w400;
const FontWeight medium = FontWeight.w500;
const FontWeight semibold = FontWeight.w600;
const FontWeight bold = FontWeight.bold;

typedef ObjectCallback<T> = void Function(T value);
typedef BoolCallback = void Function(bool value);

typedef ObjectCallbackResultN<T, N> = N Function(T value);
typedef CallbackResultN<N> = N Function();

Container quickContainer({
  double? width,
  double? height,
  AlignmentGeometry? alignment,
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
}) {
  return Container(
    width: width,
    height: height,
    margin: margin,
    padding: padding,
    alignment: alignment,
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: color,
      image: backgroundImage == null
          ? null
          : DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(
                backgroundImage,
              ),
            ),
      borderRadius: circular == null ? null : BorderRadius.circular(circular),
      boxShadow: boxShadow != null
          ? [
              boxShadow,
            ]
          : null,
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
  Color color, {
  FontWeight? fontWeight,
  TextOverflow? overflow,
  String? fontFamily,
}) {
  return Text(
    text,
    overflow: overflow,
    maxLines: overflow == null ? null : 1,
    style: TextStyle(
      fontSize: size,
      color: color,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
    ),
  );
}

Widget roundButton({
  /// borderWidth>0 使用color作为borderColor
  /// borderWidth=0 使用color作为bgColor
  required String title,
  required double fontSize,
  required Color fontColor,
  required GestureTapCallback onTap,
  Color? color,
  FontWeight? fontWeight,
  double? height,
  double? width,
  double borderWidth = 0,
  double space = 5,
  Widget? imageWidget,
  bool imageLeft = true,
}) {
  return GestureDetector(
    onTap: onTap,
    child: quickContainer(
      width: width,
      height: height,
      color: borderWidth == 0 ? color : null,
      circular: height == null ? 0 : height * 0.5,
      borderWidth: borderWidth,
      borderColor: borderWidth > 0 ? color : null,

      /// 一般有背景颜色都是纯色按钮，文本一般居中显示
      /// 无颜色一般就是文本按钮，显示最小大小
      alignment: color != null ? Alignment.center : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageWidget != null && imageLeft) imageWidget,
          if (imageWidget != null && imageLeft) SizedBox(width: space),
          quickText(title, fontSize, fontColor, fontWeight: fontWeight),
          if (imageWidget != null && !imageLeft) SizedBox(width: space),
          if (imageWidget != null && !imageLeft) imageWidget,
        ],
      ),
    ),
  );
}

Widget quickButton({
  required String text,
  required double fontSize,
  required Color fontColor,
  required VoidCallback onPressed,
  Color? backgroundColor,
  FontWeight? fontWeight,
  double? width,
  double? height,
  double? circular,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: quickContainer(
      width: width,
      height: height,
      circular: circular,
      color: backgroundColor,
      alignment: Alignment.center,
      child: quickText(text, fontSize, fontColor),
    ),
  );
}

Widget gradientButton({
  required String text,
  required List<Color> gradientColors,
  required VoidCallback onPressed,
  double fontSize = 17,
  FontWeight? fontWeight,
  Color textColor = Colors.white,
  double? width,
  double? height,
  double? circular,
}) {
  return quickContainer(
    width: width,
    height: height,
    circular: circular,
    gradientColors: gradientColors,
    child: quickButton(
      text: text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontColor: textColor,
      backgroundColor: Colors.transparent,
      onPressed: onPressed,
    ),
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
          return TextSpan(
            text: strings[index],
            style: textStyles[index],
          );
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

DecorationImage quickBgImage(String image, {BoxFit boxFit = BoxFit.fill}) {
  return DecorationImage(
    fit: boxFit,
    image: AssetImage(image),
  );
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
