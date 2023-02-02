import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';
import 'package:lj_flutter_package/ui_component/lj_password_bar.dart';

class PasswordInputPage extends StatefulWidget {
  const PasswordInputPage({Key? key}) : super(key: key);

  @override
  State<PasswordInputPage> createState() => _PasswordInputPageState();
}

class _PasswordInputPageState extends State<PasswordInputPage> {
  LJPasswordBarType _type = LJPasswordBarType.box;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            LJPasswordBar(
              width: 50,
              borderColor: Colors.orange,
              editComplete: (String code) {},
              type: _type,
            ),
            const SizedBox(height: 10),
            quickButton(
              text: '切换样式',
              onPressed: () {
                setState(() {
                  _type = _type == LJPasswordBarType.line
                      ? LJPasswordBarType.box
                      : LJPasswordBarType.line;
                });
              },
              fontColor: Colors.blue,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }
}
