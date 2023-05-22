import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';
import '../common/router.dart';
import 'model/user_info_model.dart';

const String kLoginEvent = 'LoginEvent';
const String kLogoutEvent = 'LogoutEvent';

class LoginManager {
  static UserInfoResult? userInfoResult;

  static bool get isLogin {
    return userInfoResult != null;
  }

  static logout() {
    // 清理数据
    userInfoResult = null;

    LJNetwork.headers.remove('Authorization');
    LJEventBus().emit(kLogoutEvent);
  }

  static Future<bool> showLogin(BuildContext context) async {
    if (isLogin) return Future.value(true);

    bool? result = await Navigator.pushNamed(
      context,
      LJRouter.loginPage,
    ) as bool?;

    if (result == true) {
      LJNetwork.headers.addAll({'Authorization': userInfoResult?.token ?? ""});
      LJEventBus().emit(kLoginEvent);
    }

    return result == null ? Future.value(false) : Future.value(result);
  }

  /*当前登录的手机号*/
  static String? loginPhone;

  /*当前登录的验证码*/
  static String? loginCode;
}
