import 'dart:async';

import 'package:tobias/tobias.dart';

class AlipayUtil {
  static final Tobias tobias = Tobias();

  static Future<bool> get installed => tobias.isAliPayInstalled;

  static Future pay(String order) {
    return tobias.pay(order);
  }
}
