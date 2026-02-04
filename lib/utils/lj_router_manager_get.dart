import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'lj_define.dart';

class RouterManagerGet {
  /*非必传,仅onGenerateRoute使用*/
  static List<GetPage>? getPages;

  /*所有页面都需要登录才能访问,比如后台管理,优先级最高*/
  static bool allPageNeedLogin = false;

  /*白名单页面,不需要验证登录,与下面的verifyLoginPageList二选一,哪个有值用哪个*/
  static List<String> whitePageList = [];

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

  /*not found page*/
  static String? unknownPageName;

  static bool _needLogin(String routeName) {
    bool loginStatus = false;
    if (getLoginStatus != null) loginStatus = getLoginStatus!();
    // 已经是登录状态
    if (loginStatus) return false;

    if (allPageNeedLogin) {
      return true;
    } else if (whitePageList.isNotEmpty) {
      return !whitePageList.contains(routeName);
    } else if (verifyLoginPageList.isNotEmpty) {
      return verifyLoginPageList.contains(routeName);
    }

    return false;
  }

  static pushNamed<T>(
    String routeName, {
    Object? arguments,
    ObjectCallback<T?>? popCallback,
  }) async {
    if (_needLogin(routeName)) {
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

  /*
  建议只有web端使用
  其他端只使用上面的pushNamed就能支持全部场景
  这个监听主要是处理在浏览器直接输入地址跳转这种情况
  */
  static Route onGenerateRoute(RouteSettings settings) {
    if (getPages?.isEmpty == true) {
      return _unknownPage(title: '使用onGenerateRoute请配置getPages');
    }

    if (settings.name?.isNotEmpty != true) {
      return _unknownPage();
    }

    if (_needLogin(settings.name!)) {
      GetPage? loginGetPage =
          getPages!.firstWhereOrNull((page) => page.name == loginPageName);
      if (loginPageName?.isNotEmpty == true && loginGetPage != null) {
        return GetPageRoute(settings: settings, page: loginGetPage.page);
      } else {
        return _unknownPage(title: '使用onGenerateRoute请配置loginPageName登录页');
      }
    }

    GetPage? getPage;
    if (getPages?.isNotEmpty == true) {
      getPage =
          getPages!.firstWhereOrNull((page) => page.name == settings.name);
    }

    GetPage? unknownGetPage;
    if (unknownPageName?.isNotEmpty == true) {
      unknownGetPage =
          getPages!.firstWhereOrNull((page) => page.name == unknownPageName);
    }

    return GetPageRoute(
      settings: settings,
      page: getPage?.page ?? unknownGetPage?.page ?? _unknownPage().page,
    );
  }

  static GetPageRoute _unknownPage({String? title}) {
    return GetPageRoute(page: () {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: quickText(
            title ?? '你找到了一片荒芜之地~~',
            16,
            const Color(0xFF666666),
          ),
        ),
      );
    });
  }
}
