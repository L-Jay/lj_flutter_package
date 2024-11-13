import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum LJPasswordBarType {
  box,
  line,
}

class LJPasswordBar extends StatefulWidget {
  const LJPasswordBar({
    Key? key,
    this.length = 6,
    this.width = 44,
    required this.borderColor,
    this.borderWidth = 1,
    this.fillColor,
    this.circular,
    this.obscureText = true,
    this.obscureTextString = '●',
    this.type = LJPasswordBarType.box,
    this.textStyle,
    this.keyboardType,
    this.autoFocus = false,
    this.autoFinish = false,
    required this.editComplete,
  }) : super(key: key);

  final int length;
  final double width;
  final Color borderColor;
  final double borderWidth;
  final Color? fillColor;
  final double? circular;
  final bool obscureText;
  final String obscureTextString;
  final TextStyle? textStyle;
  final LJPasswordBarType type;
  final TextInputType? keyboardType;
  final bool autoFocus;
  final bool autoFinish;
  final void Function(String code) editComplete;

  @override
  State<LJPasswordBar> createState() => _LJPasswordBarState();
}

class _LJPasswordBarState extends State<LJPasswordBar> {
  late List<TextEditingController> _controllerList;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _controllerList =
        List.generate(widget.length, (index) => TextEditingController());

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        String code = '';
        for (var controller in _controllerList) {
          code += controller.text;
        }
        widget.editComplete(code);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.autoFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllerList) {
      controller.dispose();
    }
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildGridView(),
        _buildInput(),
      ],
    );
  }

  Widget _buildInput() {
    return Positioned.fill(
      child: TextField(
        focusNode: _focusNode,
        cursorWidth: 0,
        cursorColor: Colors.transparent,
        keyboardType: widget.keyboardType ??
            const TextInputType.numberWithOptions(signed: true),
        enableInteractiveSelection: false,
        style: const TextStyle(color: Colors.transparent),
        textInputAction: TextInputAction.done,
        inputFormatters: [
          LengthLimitingTextInputFormatter(widget.length),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        onChanged: (text) {
          List list = text.split("");
          for (int i = 0; i < _controllerList.length; i++) {
            if (i < list.length) {
              _controllerList[i].text = list[i];
            } else {
              _controllerList[i].text = '';
            }
          }
          setState(() {});

          if (list.length == widget.length) {
            _editComplete();
          }
        },
        onEditingComplete: _editComplete,
      ),
    );
  }

  _editComplete() {
    String code = '';
    for (var controller in _controllerList) {
      code += controller.text;
    }
    widget.editComplete(code);

    _focusNode.unfocus();
  }

  GridView _buildGridView() {
    double surplus =
        MediaQuery
            .of(context)
            .size
            .width - widget.length * widget.width;
    double space = surplus > 0 ? surplus * 0.2 : 10;

    return GridView.builder(
      itemCount: widget.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.length,
        crossAxisSpacing: space,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          width: widget.width,
          height: widget.width,
          padding: const EdgeInsets.only(left: 3, bottom: 3),
          decoration: BoxDecoration(
            color: widget.fillColor,
            borderRadius: widget.circular != null
                ? BorderRadius.circular(widget.circular!)
                : null,
            border: widget.type == LJPasswordBarType.box
                ? Border.all(
                color: widget.borderColor, width: widget.borderWidth)
                : Border(
              bottom: BorderSide(
                width: widget.borderWidth,
                color: widget.borderColor,
              ),
            ),
          ),
          child: TextField(
            controller: _controllerList[index],
            cursorColor: Colors.transparent,
            readOnly: true,
            textAlign: TextAlign.center,
            obscureText: widget.obscureText,
            obscuringCharacter: widget.obscureTextString,
            style: widget.textStyle?.copyWith(height: 1) ??
                TextStyle(
                  fontSize: widget.width * 0.5,
                  height: 1,
                ),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        );
      },
    );
  }
}
