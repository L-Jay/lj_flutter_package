import 'dart:async';

import 'package:tobias/tobias.dart';

class AlipayUtil {
  static final Tobias tobias = Tobias();

  static Future<bool> get installed => tobias.isAliPayInstalled;

  static Future pay(String order, {bool debug = false}) async {
    var result = await tobias.pay(
        order, evn: debug ? AliPayEvn.sandbox : AliPayEvn.online);
    print(result);

    String code = result["resultStatus"];

    if (code == "9000") {
      return;
    } else if (code == "6001") {
      throw "取消支付";
    } else {
      throw "支付失败";
    }
  }
}
