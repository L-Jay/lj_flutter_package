import 'package:tobias/tobias.dart';

import 'lj_error.dart';

enum PayEvn { online, sandbox }

typedef AlipayErrorCallback = void Function(LJError error);

class AlipayUtil {
  static final Tobias tobias = Tobias();

  static Future<bool> get isAliPayInstalled => tobias.isAliPayInstalled;

  static String? _universalLink;
  static late AlipayErrorCallback _errorCallback;
  static late PayEvn _payEvn;

  static register({
    required String universalLink,
    required AlipayErrorCallback errorCallback,
    PayEvn payEvn = PayEvn.sandbox,
  }) async {
    _universalLink = universalLink;
    _errorCallback = errorCallback;
    _payEvn = payEvn;
  }

  static Future<bool> pay(String? order) async {
    if (order?.isNotEmpty != true) {
      _errorCallback(LJError(
        600,
        '失败',
      ));
      return false;
    }
    var map = await tobias.pay(
      order!,
      evn: _payEvn == PayEvn.online ? AliPayEvn.online : AliPayEvn.sandbox,
      universalLink: _universalLink,
    );
    print(map);
    return true;
  }
}
