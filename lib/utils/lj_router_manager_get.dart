import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'lj_define.dart';

class RouterManagerGet {
  /*需要验证登录态的路由*/
  static List<String> verifyLoginPageList = [];

  /*获取登录状态*/
  static bool Function()? getLoginStatus;

  /*登录回调，返回true表示登录成功，继续进行后续动作*/
  static Future<bool> Function()? doLogin;

  /*
  登录页路由名称loginPageName，doLogin同时实现的话优先使用doLogin
  登录页完成登录后，pop的时候返回true
  */
  static String? loginPageName;

  static pushNamed<T>(String routeName, {
    Object? arguments,
    ObjectCallback<T?>? popCallback,
  }) async {
    bool loginStatus = false;
    if (getLoginStatus != null) loginStatus = getLoginStatus!();
    if (verifyLoginPageList.contains(routeName) && !loginStatus) {
      bool? loginResult = false;
      if (doLogin != null) {
        loginResult = await doLogin!();
      } else if (loginPageName != null) {
        loginResult = await Get.toNamed(loginPageName!);
      }

      if (loginResult == true) {
        return Get.toNamed(routeName, arguments: arguments)?.then((value) {
          popCallback?.call(value as T);
        });
      }
    } else {
      return Get.toNamed(routeName, arguments: arguments)?.then((value) {
        popCallback?.call(value as T);
      });
    }
  }
}