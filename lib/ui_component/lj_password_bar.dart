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
    this.obscureText = true,
    this.obscureTextString = '●',
    this.type = LJPasswordBarType.box,
    this.textStyle,
    required this.editComplete,
  }) : super(key: key);

  final int length;
  final double width;
  final Color borderColor;
  final double borderWidth;
  final Color? fillColor;
  final bool obscureText;
  final String obscureTextString;
  final TextStyle? textStyle;
  final LJPasswordBarType type;
  final void Function(String code) editComplete;

  @override
  State<LJPasswordBar> createState() => _LJPasswordBarState();
}

class _LJPasswordBarState extends State<LJPasswordBar> {
  late List<TextEditingController> _controllerList;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
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

    super.initState();
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
        keyboardType: const TextInputType.numberWithOptions(signed: true),
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
        },
        onEditingComplete: () {
          String code = '';
          for (var controller in _controllerList) {
            code += controller.text;
          }
          widget.editComplete(code);

          _focusNode.unfocus();
        },
      ),
    );
  }

  GridView _buildGridView() {
    double surplus =
        MediaQuery.of(context).size.width - widget.length * widget.width;
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
