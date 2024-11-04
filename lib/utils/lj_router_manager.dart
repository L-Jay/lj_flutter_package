import 'package:flutter/material.dart';
import 'lj_define.dart';

class RouterManager {
  /*全局导航key，配置MaterialApp的navigatorKey，可以在任意地方无context push or pop*/
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /*路由表*/
  static Map routes = <String, WidgetBuilder>{};

  /*需要验证登录态的路由*/
  static List<String> verifyLoginPageList = [];

  /*需要model形态的路由*/
  static List<String> fullscreenPageList = [];

  /*全局pop callback，返回都会调用*/
  static VoidCallback? globalPopCallback;

  /*获取登录状态*/
  static bool Function()? getLoginStatus;

  /*登录回调，返回true表示登录成功，继续进行后续动作*/
  static Future<bool> Function(BuildContext context)? doLogin;
  /*
  登录页路由名称loginPageName，doLogin同时实现的话优先使用doLogin
  登录页完成登录后，pop的时候返回true
  */
  static String? loginPageName;

  static pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    ObjectCallback<T?>? popCallback,
  }) async {
    bool loginStatus = false;
    if (getLoginStatus != null) loginStatus = getLoginStatus!();
    if (verifyLoginPageList.contains(routeName) && !loginStatus) {
      bool? loginResult = false;
      if (doLogin != null) {
        loginResult = await doLogin!(context);
      }else if (loginPageName != null) {
        loginResult = await Navigator.pushNamed(context, loginPageName!) as bool?;
      }

      if (loginResult == true) {
        Navigator.pushNamed(context, routeName, arguments: arguments)
            .then((value) {
          popCallback?.call(value as T);
          globalPopCallback?.call();
        });
      }
    } else {
      Navigator.pushNamed(context, routeName, arguments: arguments)
          .then((value) {
        popCallback?.call(value as T);
        globalPopCallback?.call();
      });
    }
  }

  static MaterialPageRoute onGenerateRoute(RouteSettings settings) {
    WidgetBuilder builder = routes[settings.name];

    bool fullScreen = fullscreenPageList.contains(settings.name);

    return MaterialPageRoute(builder: builder, settings: settings, fullscreenDialog: fullScreen);
  }
}

extension StateArguments on State {
  Object? get argument {
    return ModalRoute.of(context)?.settings.arguments;
  }

  Map? get argumentMap {
    return ModalRoute.of(context)?.settings.arguments as Map;
  }
}

extension StatelessWidgetArguments on StatelessWidget {
  Object? argument(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments;
  }

  Map? argumentMap(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments as Map;
  }
}

MaterialPageRoute pageRoute(Widget page) {
  return MaterialPageRoute(
    builder: (context) => page,
  );
}