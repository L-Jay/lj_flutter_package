import 'package:flutter/material.dart';
import 'lj_define.dart';

class RouterManager {
  /*全局导航key，配置MaterialApp的navigatorKey，可以在任意地方无context push or pop*/
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /*路由表*/
  static Map routes = <String, WidgetBuilder>{};

  /*所有页面都需要登录才能访问,比如后台管理,优先级最高*/
  static bool allPageNeedLogin = false;

  /*白名单页面,不需要验证登录,与下面的verifyLoginPageList二选一,哪个有值用哪个*/
  static List<String> whitePageList = [];

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
    BuildContext context,
    String routeName, {
    Object? arguments,
    ObjectCallback<T?>? popCallback,
  }) async {
    if (_needLogin(routeName)) {
      bool? loginResult = false;
      if (doLogin != null) {
        loginResult = await doLogin!(context);
      } else if (loginPageName != null) {
        loginResult =
            await Navigator.pushNamed(context, loginPageName!) as bool?;
      }

      if (loginResult == true) {
        return Navigator.pushNamed(context, routeName, arguments: arguments)
            .then((value) {
          popCallback?.call(value as T);
          globalPopCallback?.call();
        });
      }
    } else {
      return Navigator.pushNamed(context, routeName, arguments: arguments)
          .then((value) {
        popCallback?.call(value as T);
        globalPopCallback?.call();
      });
    }
  }

  static MaterialPageRoute onGenerateRoute(RouteSettings settings) {
    if (routes.isEmpty == true) {
      return _unknownPage(title: '使用onGenerateRoute请配置routes');
    }

    if (settings.name?.isNotEmpty != true) {
      return _unknownPage();
    }

    if (_needLogin(settings.name!)) {
      var loginBuilder = routes[loginPageName];
      if (loginPageName?.isNotEmpty != true || loginBuilder == null) {
        return _unknownPage(title: '使用onGenerateRoute请配置loginPageName登录页');
      } else {
        return MaterialPageRoute(
          builder: loginBuilder,
          settings: settings,
          fullscreenDialog: isAndroid || isIOS,
        );
      }
    }

    WidgetBuilder? builder = routes[settings.name];

    WidgetBuilder? unknownGetBuilder;
    if (unknownPageName?.isNotEmpty == true) {
      unknownGetBuilder = routes[unknownPageName];
    }

    bool fullScreen = false;
    if (isIOS || isAndroid) {
      fullScreen = fullscreenPageList.contains(settings.name);
    }

    return MaterialPageRoute(
      builder: builder ?? unknownGetBuilder ?? _unknownPage().builder,
      settings: settings,
      fullscreenDialog: fullScreen,
    );
  }

  static MaterialPageRoute _unknownPage({String? title}) {
    return MaterialPageRoute(
      builder: (context) {
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
      },
    );
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
