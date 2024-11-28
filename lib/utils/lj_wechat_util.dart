import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fluwx/fluwx.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

class WeChatUtil {
  static final Fluwx fluwx = Fluwx();

  static Future<bool> get isWeChatInstalled => fluwx.isWeChatInstalled;

  static final Completer<Map<String, dynamic>> _completer = Completer();

  static register({
    required String appId,
    required String universalLink,
    required Function(LJError error) errorCallback,
  }) async {
    var result =
        await fluwx.registerApi(appId: appId, universalLink: universalLink);
    if (result) {
      if (kDebugMode) {
        fluwx.selfCheck();
      }

      fluwx.addSubscriber((response) {
        if (!response.isSuccessful) {
          errorCallback(LJError(
            response.errCode ?? 500,
            response.errStr ?? '操作识别',
          ));
          return;
        }
        if (response is WeChatPaymentResponse) {
          /// 支付
          _completer.complete({});
        } else if (response is WeChatAuthResponse) {
          /// 登录
          _completer.complete({
            'code': response.code,
            'state': response.state,
          });
        } else if (response is WeChatShareResponse) {
          /// 分享
          _completer.complete({});
        }
      });
    }
  }

  static Future<Map<String, dynamic>> login() {
    var scope = 'snsapi_userinfo';
    var state = LJUtil.packageInfo.appName;
    var authType = Platform.isIOS
        ? PhoneLogin(scope: scope, state: state)
        : NormalAuth(scope: scope, state: state);
    fluwx.authBy(which: authType);

    return _completer.future;
  }

  static Future<Map<String, dynamic>> pay({
    required String appId,
    required String partnerId,
    required String prepayId,
    required String packageValue,
    required String nonceStr,
    required int timestamp,
    required String sign,
  }) {
    fluwx.pay(
      which: Payment(
        appId: appId,
        partnerId: partnerId,
        prepayId: prepayId,
        packageValue: packageValue,
        nonceStr: nonceStr,
        timestamp: timestamp,
        sign: sign,
      ),
    );

    return _completer.future;
  }

  static Future shareText(String text, [bool session = true]) {
    fluwx.share(WeChatShareTextModel(
      text,
      scene: session ? WeChatScene.session : WeChatScene.timeline,
    ));
    return _completer.future;
  }

  static Future shareImage(Uint8List image, [bool session = true]) {
    fluwx.share(WeChatShareImageModel(
      WeChatImageToShare(uint8List: image),
      scene: session ? WeChatScene.session : WeChatScene.timeline,
    ));
    return _completer.future;
  }

  static Future shareWeb({
    required String url,
    String? title,
    Uint8List? thumbData,
    bool session = true,
  }) {
    fluwx.share(WeChatShareWebPageModel(
      url,
      title: title,
      thumbData: thumbData,
      scene: session ? WeChatScene.session : WeChatScene.timeline,
    ));
    return _completer.future;
  }

  static Future shareMiniProgram({
    required String webpageUrl,
    required String userName,
    String? path,
    Uint8List? thumbData,
    bool isTest = false,
  }) {
    fluwx.share(WeChatShareMiniProgramModel(
      webPageUrl: webpageUrl,
      userName: userName,
      path: path ?? '/',
      miniProgramType:
          isTest ? WXMiniProgramType.test : WXMiniProgramType.release,
    ));
    return _completer.future;
  }
}
