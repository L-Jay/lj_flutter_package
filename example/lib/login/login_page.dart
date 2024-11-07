import 'dart:async';
import 'dart:math';

import 'package:example/common/api_url.dart';
import 'package:example/login/model/user_info_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';
import 'package:lj_flutter_package/ui_component/lj_imagebutton.dart';
import 'package:lj_flutter_package/ui_component/lj_send_code_button.dart';
import 'package:lj_flutter_package/ui_component/lj_webview_page.dart';
import 'package:rxdart/rxdart.dart';

import '../common/lj_colors.dart';
import 'login_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  Future<bool> _fetchCode() async {
    LJNetwork.mockMap[ApiUrl.sendCode] = (Map<String, dynamic>? requestParams) {
      int randomCode = Random().nextInt(999999);
      String code = randomCode.toString().padLeft(6, '0');

      return '''
        {
    "reason": "获取验证码成功\\n$code",
    "error_code": 0,
    "result": $code
}
''';
    };

    EasyLoading.show();
    Completer<bool> completer = Completer();
    LJNetwork.post(
      ApiUrl.sendCode,
      data: {
        'loginMobile': _phoneController.text,
      },
      successCallback: (Map data) {
        int? code = data['result'];
        LoginManager.loginPhone = _phoneController.text;
        LoginManager.loginCode = code?.toString();

        EasyLoading.showSuccess(data['reason']);
        completer.complete(true);
      },
      failureCallback: (error) {
        EasyLoading.showError(error.errorMessage);
        completer.complete(false);
        print(error);
      },
    );

    return completer.future;
  }

  _doLogin() async {
    if (!isAgreeCheck) {
      EasyLoading.showError('请阅读并勾选协议');
      return;
    }
    if (!_phoneController.text.verifyPhone()) {
      EasyLoading.showError('请输入正确的手机号');
      return;
    }

    if (_codeController.text.length < 4) {
      EasyLoading.showError('请输入正确的验证码');
      return;
    }

    LJNetwork.mockMap[ApiUrl.mobileLogin] =
        (Map<String, dynamic>? requestParams) {
      String phone = requestParams?['phone'];
      String code = requestParams?['code'];

      if (phone == LoginManager.loginPhone && code == LoginManager.loginCode) {
        return '''
          {
    "reason": "登录成功",
    "error_code": 0,
    "result": {
        "userId": 5486,
        "avatarUrl": "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Finews.gtimg.com%2Fnewsapp_bt%2F0%2F13236652030%2F1000.jpg&refer=http%3A%2F%2Finews.gtimg.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1661264259&t=702c01270384b8313c1b940ffec3946d",
        "nikeName": "伍六七",
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
    }
}
''';
      } else {
        return '''
          {
    "reason": "验证码错误",
    "error_code": 400
}
''';
      }
    };

    EasyLoading.show();
    LJNetwork.post<UserInfoModel>(
      '/login',
      data: {
        'phone': _phoneController.text,
        'code': _codeController.text,
      },
      successCallback: (UserInfoModel model) {
        LoginManager.userInfoResult = model.result;
        EasyLoading.showSuccess(model.reason!);
        Navigator.pop(context, true);
      },
      failureCallback: (error) {
        EasyLoading.showError(error.errorMessage);
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              _inputItem(_phoneController),
              const SizedBox(height: 20),
              _inputItem(_codeController),
              const SizedBox(height: 36),
              _buildPrivacy(),
              const SizedBox(height: 20),
              _buildLoginButton(context),
            ],
          ),
        ),
      ),
    );
  }

  bool isAgreeCheck = false;
  final PublishSubject<bool> _agreeCheckSubject = PublishSubject();

  Widget _buildPrivacy() {
    return LJImageButton(
      onTap: () {
        isAgreeCheck = !isAgreeCheck;
        _agreeCheckSubject.add(isAgreeCheck);
      },
      spaceMargin: 5.5,
      imageChild: StreamBuilder(
        stream: _agreeCheckSubject.stream,
        builder: (context, value) {
          return Icon(
            isAgreeCheck
                ? Icons.check_circle_sharp
                : Icons.check_circle_outline_sharp,
            color: isAgreeCheck ? LJColor.mainColor : LJColor.lightGaryColor,
            size: 20,
          );
        },
      ),
      textChild: quickRichTextTap(
        12,
        ['我已阅读并同意', '《用户服务协议》', '&', '《隐私条款》'],
        [
          LJColor.lightGaryColor,
          LJColor.garyColor,
          LJColor.lightGaryColor,
          LJColor.garyColor
        ],
        [
          () {},
          () {
            Navigator.push(
              context,
              pageRoute(
                const LJWebViewPage(url: 'https://www.baidu.com'),
              ),
            );
          },
          () {},
          () {
            Navigator.push(
              context,
              pageRoute(
                const LJWebViewPage(url: 'https://www.baidu.com'),
              ),
            );
          },
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: TextButton(
        onPressed: () {
          _doLogin();
        },
        style: buttonStyle(
          16,
          Colors.white,
          backgroundColor: LJColor.mainColor,
        ),
        child: const Text('登录'),
      ),
    );
  }

  Widget _inputItem(TextEditingController controller) {
    late String title;
    List<TextInputFormatter> formatter = [];
    TextInputType inputType = TextInputType.text;
    String? hintText;
    bool obscure = false;

    if (controller == _codeController) {
      title = '验证码';
      // hintText = '请输入验证码';
      formatter = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ];
    } else if (controller == _phoneController) {
      title = '手机号';
      // hintText = '输入手机号';
      formatter = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ];
    }

    return Container(
      height: 46.5,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: LJColor.textColor,
                      fontSize: 16,
                      fontWeight: bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      controller: controller,
                      inputFormatters: formatter,
                      keyboardType: inputType,
                      obscureText: obscure,
                      enableInteractiveSelection: false,
                      style: const TextStyle(
                        color: LJColor.textColor,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: LJColor.hintColor,
                        ),
                        isDense: true,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                if (controller == _codeController)
                  SendCodeButton(
                    controller: _phoneController,
                    fontSize: 12,
                    isShowBorder: false,
                    disableColor: LJColor.hintColor,
                    enableColor: LJColor.mainColor,
                    sendCodeMethod: () {
                      return _fetchCode();
                    },
                  ),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
