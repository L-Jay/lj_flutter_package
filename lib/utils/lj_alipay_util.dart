import 'dart:async';

import 'package:alipay_kit/alipay_kit.dart';

import 'lj_error.dart';

///所有方法只有成功才返回
///所有错误使用register的errorCallback处理
class AlipayUtil {
  static final instance = AlipayKitPlatform.instance;

  static Future<bool> get installed => instance.isInstalled();
  static Completer _completer = Completer();

  static register({
    required Function(LJError error) errorCallback,
  }) async {
    instance.payResp().listen((AlipayResp resp) {
      if (resp.resultStatus == 9000) {
        _completer.complete();
      } else {
        errorCallback(LJError(
          resp.resultStatus ?? 600,
          resp.memo?.isNotEmpty == true ? resp.memo! : '支付失败',
        ));
      }
    });
  }

  static Future pay(String order) {
    _completer = Completer();
    instance.pay(orderInfo: order);
    return _completer.future;
  }
}
