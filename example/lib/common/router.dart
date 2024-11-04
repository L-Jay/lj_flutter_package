import 'package:example/bottom_tabbar.dart';
import 'package:flutter/widgets.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

import '../demo_pages/pages/drag_demo_page.dart';
import '../login/login_page.dart';
import '../order/order_page.dart';
import '../setting/setting_page.dart';

class LJRouter {
  static Map<String, WidgetBuilder> routes = {
    orderPage: (context) => const OrderPage(),
    dragDemoPage: (context) => const DragDemoPage(),
    loginPage: (context) => const LoginPage(),
    settingPage: (context) => const SettingPage(),

  };

  static List<GetPage> pages = [
    GetPage(name: root, page: () => const BottomTabbar()),
    GetPage(name: orderPage, page: () => const OrderPage()),
    GetPage(name: dragDemoPage, page: () => const DragDemoPage()),
    GetPage(name: loginPage, page: () => const LoginPage(), fullscreenDialog: true),
    GetPage(name: settingPage, page: () => const SettingPage()),
  ];

  static List<String> verifyLoginPageList = [
    orderPage,
  ];

  static List<String> fullscreenPageList = [
    loginPage,
  ];

  static String root = '/';
  static String orderPage = '/orderPage';
  static String dragDemoPage = '/dragDemoPage';
  static String loginPage = '/loginPage';
  static String settingPage = '/settingPage';
}
