import 'dart:io';

import 'package:example/bottom_tabbar.dart';
import 'package:example/common/api_url.dart';
import 'package:example/common/lj_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'common/router.dart';
import 'generated/json/base/json_convert_content.dart';
import 'login/login_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  MyApp({super.key}) {
    _configNetwork();
    // _configRouter();
    _configGetRouter();
  }

  void _configNetwork() {
    // LJNetwork.baseUrl = 'http://apis.juhe.cn';
    LJNetwork.codeKey = 'error_code';
    LJNetwork.successCode = 0;
    LJNetwork.messageKey = 'reason';
    LJNetwork.headers.addAll({
      'Authorization': LoginManager.userInfoResult?.token ?? "",
    });

    LJNetwork.handleAllFailureCallBack = (error) {
      // 登录过期
      if (error.errorCode == 401) {
        LoginManager.logout();
      }

      EasyLoading.showError(error.errorMessage);
    };
    LJNetwork.jsonParse = <T>(data) {
      return JsonConvert.fromJsonAsT<T>(data) as T;
    };

    // 拦截请求参数
    LJNetwork.handleRequestParams =
        (String path, Map<String, dynamic>? requestParams) {
      EasyLoading.show();
      return requestParams ?? {};
    };

    // 拦截响应体
    LJNetwork.handleResponseData =
        (String path, Map<String, dynamic> responseData) {
      EasyLoading.dismiss();
      return responseData;
    };
  }

  _configRouter() {
    RouterManager.routes = LJRouter.routes;
    RouterManager.verifyLoginPageList = LJRouter.verifyLoginPageList;
    RouterManager.fullscreenPageList = LJRouter.fullscreenPageList;
    RouterManager.doLogin = (BuildContext context) {
      return LoginManager.showLogin(context);
    };
    RouterManager.loginPageName = LJRouter.loginPage;
    RouterManager.getLoginStatus = () {
      return LoginManager.isLogin;
    };
    RouterManager.globalPopCallback = () {
      EasyLoading.dismiss();
    };
  }

  _configGetRouter() {
    RouterManagerGet.verifyLoginPageList = LJRouter.verifyLoginPageList;
    // RouterManagerGet.doLogin = () {
    //   return LoginManager.showLogin();
    // };
    RouterManagerGet.loginPageName = LJRouter.loginPage;
    RouterManagerGet.getLoginStatus = () {
      return LoginManager.isLogin;
    };
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      headerBuilder: () => const WaterDropHeader(
        refresh: Text("正在刷新"),
        complete: Text("刷新完成"),
      ),
      // 配置默认头部指示器,假如你每个页面的头部指示器都一样的话,你需要设置这个
      footerBuilder: () => const ClassicFooter(
        loadStyle: LoadStyle.ShowWhenLoading,
        loadingText: "正在加载",
        canLoadingText: "松手刷新",
        failedText: "刷新完成",
        noDataText: "我是有底线哒～",
      ),
      maxOverScrollExtent: 100,
      maxUnderScrollExtent: 0,
      enableScrollWhenRefreshCompleted: true,
      enableLoadingWhenFailed: true,
      hideFooterWhenNotFull: true,
      enableBallisticLoad: true,
      // child: _buildMaterialApp(),
      child: _buildGetMaterialApp(),
    );
  }

  MaterialApp _buildMaterialApp() {
    return MaterialApp(
      title: 'lj_package demo',
      // navigatorKey: RouterManager.navigatorKey,
      theme: ThemeData(
        fontFamily: "PingFang",
        brightness: Brightness.light,
        primaryColor: Colors.white,
        highlightColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          toolbarTextStyle: TextStyle(
            fontSize: 18,
            color: LJColor.textColor,
            fontWeight: semibold,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: LJColor.dividerColor,
          thickness: 1,
          space: 1,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BottomTabbar(),
      builder: EasyLoading.init(),
    );
  }

  GetMaterialApp _buildGetMaterialApp() {
    return GetMaterialApp(
      title: 'lj_package demo',
      builder: EasyLoading.init(),
      // initialRoute: '/',
      getPages: LJRouter.pages,
    );
  }
}
