import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'lj_define.dart';

/// 路由类型
/// goRouter: go_router包，https://pub.dev/packages/go_router, 官方推荐，Web 首选
///             地址栏实时同步完整 URL（如 #/detail/1001?name=测试商品）
///             刷新页面后参数从 URL 解析，完全不会丢失；路由历史自动恢复
///             浏览器返回 / 前进按钮与应用路由完全同步，体验和原生 Web 一致
///             支持深度链接、SEO 友好
/// get: get包，https://pub.dev/packages/get
///             适合移动端为主、Web 端仅做辅助展示的项目
///             地址栏会同步路由路径（如 #/detail）
///             参数仅保存在内存中，刷新页面后 Get.arguments 为 null，参数丢失
///             浏览器返回按钮仅能回退 URL，应用内路由栈不同步，容易出现页面与 URL 不匹配
/// navigator1: Navigator 1.0,原生路由
///             仅适合纯移动端项目，Web端体验差
///             地址栏不会同步路由路径，仅显示根路径 #/
///             刷新页面后路由栈清空，参数完全丢失
///             浏览器返回 / 前进按钮完全无效
enum RouterType {
  goRouter,
  get,
  navigator1,
}

typedef PageBuilder = Widget Function();

class RouterManager {
  /// 路由类型,默认GoRouter
  static RouterType routerType = RouterType.goRouter;

  /// 命名路由表,name page
  static Map routes = <String, PageBuilder>{};

  static GoRouter get goRouter => _goRouterImpl();

  /// Get用的路由表,name page
  static List<GetPage> get getPages => _getPagesImpl();

  /// Navigator1.0 routes,不建议使用,建议使用onGenerateRoute
  /// routes优先级比onGenerateRoute高,routes命中的path不会再走onGenerateRoute
  static Map<String, WidgetBuilder> get navigatorRoutes => routes
      .map((name, pageFunction) => MapEntry(name, (context) => pageFunction()));

  /// Navigator 1.0 结合navigatorKey使用,Get内置了,上面的goRouter绑定了这个key
  /// Navigator 1.0 最初是为移动端设计的，本身没有「地址栏 URL」的概念,建议使用GoRouter
  /// 全局导航key，配置MaterialApp的navigatorKey，可以在任意地方无context push or pop
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 获取当前可用的BuildContext,如果返回 null,表示路由尚未初始化或当前无页面显示
  /// 使用GoRouter的话不要使用context.argument去获取参数,会报错
  static BuildContext? get context => _contextImpl();

  /// 获取当前可用的Overlay context,如果返回 null,表示路由尚未初始化或当前无页面显示
  static BuildContext? get overlayContext => _overlayContextImpl();

  /// 如果调用处有context,优先使用context.argument
  /// 这个属性在动画专场中可能会出现参数错乱的情况
  static Object? get argument => _argumentImpl();

  /// 如果调用处有context,优先使用context.argumentMap
  /// 这个属性在动画专场中可能会出现参数错乱的情况
  static Map<String, dynamic>? get argumentMap => _argumentMapImpl();

  /// 当前路由名称
  static String? get currentRoute => _currentRoute;

  /// 路由历史记录
  static List<String>? get routeHistory => _routeHistory;

  /// 是否可以重复弹出相同的页面
  static bool duplicate = false;

  /// 所有页面都需要登录才能访问,比如后台管理,优先级最高
  static bool allPageNeedLogin = false;

  /// 白名单页面,不需要验证登录
  /// 与下面的verifyLoginPageList二选一,哪个有值用哪个
  static List<String> whitePageList = [];

  /// 需要验证登录态的路由
  static List<String> verifyLoginPageList = [];

  /// 需要model形态的路由
  static List<String> fullscreenPageList = [];

  /// 全局pop callback，返回都会调用
  static VoidCallback? globalPopCallback;

  /// 获取登录状态
  static bool Function()? getLoginStatus;

  /// 登录回调，返回true表示登录成功，继续进行后续动作
  /// 适应场景: 自行处理登录逻辑,高度自定义,任意跳转,任意登录方式
  static Future<bool> Function()? doLogin;

  /// 根页面路由名称rootPageName,默认 '/'
  static String rootPageName = '/';

  /// 对应的page要放在routes里面
  /// 登录页路由名称loginPageName,doLogin同时实现的话优先使用doLogin
  /// 登录页完成登录后,pop的时候需要返回true,才能跳转页面
  static String? loginPageName;

  /// 对应的page要放在routes里面
  /// not found page
  static String? unknownPageName;

  /// push named
  static pushNamed<T>(
    String routeName, {
    Object? arguments,
    ObjectCallback<T?>? popCallback,
  }) async {
    return _toNamed(routeName, arguments, popCallback, false);
  }

  /// replace named
  static replaceNamed<T>(
    String routeName, {
    Object? arguments,
    ObjectCallback<T?>? popCallback,
  }) async {
    return _toNamed(routeName, arguments, popCallback, true);
  }

  static _toNamed<T>(
    String routeName,
    Object? arguments,
    ObjectCallback<T?>? popCallback,
    bool isReplace,
  ) async {
    if (!duplicate && _currentRoute == routeName) return;

    var tempRouteName = _currentRoute;

    if (_needLogin(routeName)) {
      _currentRoute = loginPageName!;
      _routeHistory.add(loginPageName!);

      bool? loginResult = false;
      if (doLogin != null) {
        loginResult = await doLogin!();
      } else if (loginPageName != null) {
        switch (routerType) {
          case RouterType.goRouter:
            loginResult = await _goRouter?.pushNamed<bool>(loginPageName!);
            break;
          case RouterType.get:
            loginResult = await Get.toNamed(loginPageName!);
            break;
          case RouterType.navigator1:
            loginResult = (await Navigator.pushNamed(
                navigatorKey.currentContext!, loginPageName!)) as bool?;
            break;
        }
      }

      _routeHistory.removeLast();
      if (loginResult == false) {
        _currentRoute = tempRouteName;
        return;
      }
    }

    _currentRoute = routeName;
    if (routerType == RouterType.goRouter) {
      // goRouter replace不会调用pop回调_popCallbackImpl
      if (isReplace) _routeHistory.removeLast();
      _routeHistory.add(routeName);
    } else {
      if (isReplace) {
        // replace会调用pop回调_popCallbackImpl
        _routeHistory.insert(_routeHistory.length - 1, routeName);
      } else {
        _routeHistory.add(routeName);
      }
    }

    switch (routerType) {
      case RouterType.goRouter:
        if (isReplace) {
          return _goRouter
              ?.replaceNamed<T>(
                routeName,
                queryParameters:
                    arguments is Map<String, dynamic> ? arguments : {},
                extra: arguments,
              )
              .then((value) => _popCallbackImpl(value, popCallback));
        }

        return _goRouter
            ?.pushNamed<T>(
              routeName,
              queryParameters:
                  arguments is Map<String, dynamic> ? arguments : {},
              extra: arguments,
            )
            .then((value) => _popCallbackImpl(value, popCallback));
      case RouterType.get:
        if (isReplace) {
          return Get.offNamed(
            routeName,
            arguments: arguments,
            parameters: _getWebParams(arguments),
            preventDuplicates: !duplicate,
          )?.then((value) => _popCallbackImpl<T>(value, popCallback));
        }

        return Get.toNamed(
          routeName,
          arguments: arguments,
          parameters: _getWebParams(arguments),
          preventDuplicates: !duplicate,
        )?.then((value) => _popCallbackImpl<T>(value, popCallback));
      case RouterType.navigator1:
        if (isReplace) {
          return Navigator.pushReplacementNamed<T, Object?>(
            navigatorKey.currentContext!,
            routeName,
            arguments: arguments,
          ).then((value) => _popCallbackImpl(value, popCallback));
        }

        return Navigator.pushNamed<T>(
          navigatorKey.currentContext!,
          routeName,
          arguments: arguments,
        ).then((value) => _popCallbackImpl(value, popCallback));
    }
  }

  /// push到简单的页面,没有复杂逻辑,适合设置/用户协议这种没有逻辑的页面
  static pushPage<T>(Widget page) async {
    switch (routerType) {
      case RouterType.get:
        return Get.to<T>(() => page);
      case RouterType.goRouter:
      case RouterType.navigator1:
        return Navigator.push<T>(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => page),
        );
    }
  }

  /// 返回上一页
  /// [result] 返回结果，上一个页面的 await pushNamed 可以接收到
  static void pop<T>([T? result]) {
    switch (routerType) {
      case RouterType.goRouter:
        if (goRouter.canPop()) {
          goRouter.pop(result);
        }
        break;
      case RouterType.get:
        Get.back(result: result);
        break;
      case RouterType.navigator1:
        navigatorKey.currentState?.pop(result);
        break;
    }
  }

  /// 当前是否可以返回
  static bool canPop() {
    switch (routerType) {
      case RouterType.goRouter:
        return goRouter.canPop() ||
            (navigatorKey.currentState?.canPop() ?? false);
      case RouterType.get:
      case RouterType.navigator1:
        return navigatorKey.currentState?.canPop() ?? false;
    }
  }

  /// 返回指定页面，并关闭中间所有页面
  /// [routeName] 目标路由名称（GoRouter 为路径，GetX/Navigator1.0 为 routeName）
  static void popUntil(String routeName) {
    switch (routerType) {
      case RouterType.goRouter:
        goRouter.go(routeName);
        break;
      case RouterType.get:
        Get.until((route) => route.settings.name == routeName);
        break;
      case RouterType.navigator1:
        navigatorKey.currentState?.popUntil(
          (route) => route.settings.name == routeName,
        );
        break;
    }
  }

  static MaterialPageRoute onGenerateRoute(RouteSettings settings) {
    String? routeName = settings.name;

    if (routeName?.isNotEmpty != true) {
      return _unknownPage();
    }

    if (kIsWeb && routerType == RouterType.get) {
      var uri = Uri.parse(routeName!);
      routeName = uri.path;

      if (settings.arguments == null && uri.queryParameters.isNotEmpty) {
        settings = RouteSettings(
          name: settings.name,
          arguments: uri.queryParameters,
        );
      }
    }

    // 只web在地址栏输入的路由，需要拦截判断登录
    if (kIsWeb && _needLogin(routeName!)) {
      var loginBuilder = navigatorRoutes[loginPageName];
      if (loginPageName?.isNotEmpty != true || loginBuilder == null) {
        return _unknownPage(title: '使用onGenerateRoute请配置loginPageName登录页');
      } else {
        _currentRoute = loginPageName!;
        return MaterialPageRoute(
          builder: loginBuilder,
          settings: settings,
          fullscreenDialog: isAndroid || isIOS,
        );
      }
    }

    _currentRoute = routeName!;
    _currentArgument = settings.arguments;

    WidgetBuilder? builder = navigatorRoutes[routeName];

    WidgetBuilder? unknownGetBuilder;
    if (unknownPageName?.isNotEmpty == true) {
      unknownGetBuilder = navigatorRoutes[unknownPageName];
    }

    bool fullScreen = false;
    if (isIOS || isAndroid) {
      fullScreen = fullscreenPageList.contains(routeName);
    }

    return MaterialPageRoute(
      builder: builder ?? unknownGetBuilder ?? _unknownPage().builder,
      settings: settings,
      fullscreenDialog: fullScreen,
    );
  }

  static bool _needLogin(String routeName) {
    if (routeName == loginPageName) return false;

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

  /// GoRouter
  static GoRouter? _goRouter;

  static GoRouter _goRouterImpl() {
    GoRouter.optionURLReflectsImperativeAPIs = true;

    if (_goRouter != null) return _goRouter!;
    _goRouter = GoRouter(
      debugLogDiagnostics: kDebugMode,
      initialLocation: rootPageName,
      restorationScopeId: 'lj_router_manager_router',
      navigatorKey: navigatorKey,
      routes: routes.entries.map(
        (e) {
          if (e.key == loginPageName || fullscreenPageList.contains(e.key)) {
            return GoRoute(
              path: e.key,
              name: e.key,
              pageBuilder: (context, state) {
                return MaterialPage(
                  fullscreenDialog: true,
                  child: routes[e.key](),
                );
              },
            );
          }

          return GoRoute(
            path: e.key,
            name: e.key,
            builder: (context, state) => e.value(),
          );
        },
      ).toList(),
      redirect: kIsWeb
          ? (context, state) {
              if (_needLogin(state.matchedLocation)) {
                final targetPath = Uri.encodeComponent(state.matchedLocation);
                return '/$loginPageName?redirect=$targetPath';
              }

              return null;
            }
          : null,
      errorBuilder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: quickText(
              '你找到了一片荒芜之地~~',
              16,
              const Color(0xFF666666),
            ),
          ),
        );
      },
    );

    return _goRouter!;
  }

  static List<GetPage> _getPagesImpl() {
    return routes
        .map(
          (name, pageFunction) => MapEntry(
            name,
            GetPage(
              name: name,
              page: () => pageFunction(),
              fullscreenDialog:
                  (isAndroid || isIOS) && fullscreenPageList.contains(name),
            ),
          ),
        )
        .values
        .toList();
  }

  static BuildContext? _contextImpl() {
    switch (routerType) {
      case RouterType.goRouter:
      case RouterType.navigator1:
        return navigatorKey.currentContext;
      case RouterType.get:
        return Get.context;
    }
  }

  static BuildContext? _overlayContextImpl() {
    switch (routerType) {
      case RouterType.goRouter:
      case RouterType.navigator1:
        return navigatorKey.currentState?.overlay?.context;
      case RouterType.get:
        return Get.overlayContext;
    }
  }

  static Object? _argumentImpl() {
    switch (RouterManager.routerType) {
      case RouterType.navigator1:
        return _currentArgument;
      case RouterType.get:
        return Get.arguments;
      case RouterType.goRouter:
        return _goRouter!.state.extra;
    }
  }

  static Map<String, dynamic>? _argumentMapImpl() {
    switch (RouterManager.routerType) {
      case RouterType.navigator1:
        return _currentArgument is Map<String, dynamic>
            ? _currentArgument
            : null;
      case RouterType.get:
        return Get.arguments is Map<String, dynamic> ? Get.arguments : null;
      case RouterType.goRouter:
        var arguments = <String, dynamic>{};
        arguments.addAll(_goRouter!.state.pathParameters);
        arguments.addAll(_goRouter!.state.uri.queryParameters);
        if (_goRouter!.state.extra is Map<String, dynamic>) {
          arguments.addAll(_goRouter!.state.extra as Map<String, dynamic>);
        }
        return arguments.isNotEmpty ? arguments : null;
    }
  }

  static String _currentRoute = rootPageName;
  static final List<String> _routeHistory = [rootPageName];
  static dynamic _currentArgument;

// get路由web网页参数
  static Map<String, String>? _getWebParams(Object? arguments) {
    Map<String, String>? parameters;
    if (kIsWeb && arguments is Map<String, dynamic>) {
      bool allValueIsString = arguments.values.every((v) => v is String);
      if (allValueIsString) parameters = arguments.cast<String, String>();
    }
    return parameters;
  }

  static T? _popCallbackImpl<T>(T? value, ObjectCallback<T?>? popCallback) {
    _routeHistory.removeLast();
    _currentRoute = _routeHistory.last;
    popCallback?.call(value);
    globalPopCallback?.call();

    return value;
  }
}

extension RouterArguments on BuildContext {
  /// 传的Object,使用argument
  Object? get argument {
    switch (RouterManager.routerType) {
      case RouterType.navigator1:
        return ModalRoute.of(this)?.settings.arguments;
      case RouterType.get:
        return Get.arguments;
      case RouterType.goRouter:
        return GoRouterState.of(this).extra;
    }
  }

  /// 传的Map,使用argumentMap
  Map<String, dynamic>? get argumentMap {
    switch (RouterManager.routerType) {
      case RouterType.navigator1:
        final arg = ModalRoute.of(this)?.settings.arguments;
        return arg is Map<String, dynamic> ? arg : null;
      case RouterType.get:
        return Get.arguments is Map<String, dynamic> ? Get.arguments : null;
      case RouterType.goRouter:
        var state = GoRouterState.of(this);
        var arguments = <String, dynamic>{};
        arguments.addAll(state.pathParameters);
        arguments.addAll(state.uri.queryParameters);
        if (state.extra is Map<String, dynamic>) {
          arguments.addAll(state.extra as Map<String, dynamic>);
        }
        return arguments.isNotEmpty ? arguments : null;
    }
  }

  T? argumentForKey<T>(String key) {
    final value = argumentMap?[key];
    return value is T ? value : null;
  }
}
