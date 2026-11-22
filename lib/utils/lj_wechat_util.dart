import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fluwx/fluwx.dart';

import 'lj_error.dart';
import 'lj_util.dart';

///所有方法只有成功才返回
///所有错误使用register的errorCallback处理
class WechatUtil {
  static final Fluwx fluwx = Fluwx();

  static Future<bool> get installed => fluwx.isWeChatInstalled;

  static Completer _completer = Completer();

  static String _errorMessage = '失败';

  static register({
    required String appId,
    required String universalLink,
    required Function(LJError error) errorCallback,
    bool check = kDebugMode,
  }) async {
    var result =
        await fluwx.registerApi(appId: appId, universalLink: universalLink);
    if (result) {
      if (check) {
        fluwx.selfCheck();
      }

      fluwx.addSubscriber((response) {
        if (!response.isSuccessful) {
          errorCallback(LJError(
            response.errCode ?? 600,
            response.errStr?.isNotEmpty == true
                ? response.errStr!
                : _errorMessage,
          ));
          return;
        }
        if (response is WeChatPaymentResponse) {
          /// 支付
          _completer.complete();
        } else if (response is WeChatAuthResponse) {
          /// 登录
          _completer.complete({
            'code': response.code,
            'state': response.state,
          });
        } else if (response is WeChatShareResponse) {
          /// 分享
          _completer.complete();
        }
      });
    }
  }

  static Future<Map<String, dynamic>> login() {
    var completer = Completer<Map<String, dynamic>>();
    _completer = completer;

    _errorMessage = '登录失败';

    var scope = 'snsapi_userinfo';
    var state = LJUtil.packageInfo.appName;
    var authType = Platform.isIOS
        ? PhoneLogin(scope: scope, state: state)
        : NormalAuth(scope: scope, state: state);
    fluwx.authBy(which: authType);

    return completer.future;
  }

  static Future pay({
    required String appId,
    required String partnerId,
    required String prepayId,
    required String packageValue,
    required String nonceStr,
    required int timestamp,
    required String sign,
  }) async {
    _completer = Completer();
    _errorMessage = '支付失败';

    final started = await fluwx.pay(
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

    /// 微信拉起失败（如配置了 no_pay、未安装微信等）时
    /// 原生直接返回 false，不会有回调，这里主动结束避免永久挂起
    if (!started && !_completer.isCompleted) {
      _completer.completeError(LJError(600, _errorMessage));
    }

    return _completer.future;
  }

  static Future shareText(String text, [bool session = true]) {
    _completer = Completer();
    _errorMessage = '分享失败';

    fluwx.share(WeChatShareTextModel(
      text,
      scene: session ? WeChatScene.session : WeChatScene.timeline,
    ));

    return _completer.future;
  }

  static Future shareImage(Uint8List image, [bool session = true]) {
    _completer = Completer();
    _errorMessage = '分享失败';

    fluwx.share(WeChatShareImageModel(
      WeChatImageToShare(uint8List: image),
      scene: session ? WeChatScene.session : WeChatScene.timeline,
    ));
    return _completer.future;
  }

  static Future shareWeb({
    required String url,
    String? title,
    String? description,
    Uint8List? thumbData,
    bool session = true,
  }) {
    _completer = Completer();
    _errorMessage = '分享失败';

    fluwx.share(WeChatShareWebPageModel(
      url,
      title: title,
      description: description,
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
    _completer = Completer();
    _errorMessage = '分享失败';

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
