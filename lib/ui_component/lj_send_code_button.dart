import 'dart:async';

import 'package:flutter/material.dart';

class SendCodeButton extends StatefulWidget {
  final TextEditingController controller;
  final double? radius;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final double fontSize;
  final bool isShowBorder;
  final bool enable;
  final Color enableColor;
  final Color disableColor;
  final int second;
  final Future<bool> Function() sendCodeMethod;

  const SendCodeButton({
    Key? key,
    required this.controller,
    required this.sendCodeMethod,
    this.radius,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.fontSize = 14,
    this.isShowBorder = true,
    this.enable = false,
    this.second = 60,
    this.enableColor = Colors.blue,
    this.disableColor = Colors.grey,
  }) : super(key: key);

  @override
  State<SendCodeButton> createState() => _SendCodeButtonState();
}

class _SendCodeButtonState extends State<SendCodeButton> {
  String get phone => widget.controller.text;

  Timer? timer;

  late bool enable;

  @override
  void initState() {
    super.initState();

    enable = widget.enable;

    widget.controller.addListener(() {
      enable = _verifyPhone(phone) && !(timer?.isActive ?? false);
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(SendCodeButton oldWidget) {
    enable = _verifyPhone(phone) && !(timer?.isActive ?? false);
    super.didUpdateWidget(oldWidget);
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timer.tick >= widget.second) {
          timer.cancel();
          enable = true;
        } else {
          enable = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _sendCode();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        alignment: Alignment.center,
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: widget.radius == null ? null : BorderRadius.circular(widget.radius!),
          border: widget.isShowBorder
              ? Border.all(
                  color: enable ? widget.enableColor : widget.disableColor,
                )
              : null,
        ),
        child: Text(
          timer?.isActive ?? false
              ? "${(widget.second - timer!.tick)}s后重试"
              : "发送验证码",
          style: TextStyle(
            color: enable ? widget.enableColor : widget.disableColor,
            fontSize: widget.fontSize,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  _sendCode() async {
    if (!enable) {
      return;
    }

    bool result = await widget.sendCodeMethod();

    if (result) {
      startTimer();
    }
  }

  bool _verifyPhone(String phone) {
    RegExp exp = RegExp(
        r'^((13\d)|(14\d)|(15\d)|(16\d)|(17\d)|(18\d)|(19\d))\d{8}$');
    bool matched = exp.hasMatch(phone);

    return matched;
  }
}