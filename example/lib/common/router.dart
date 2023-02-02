
import 'package:flutter/widgets.dart';

import '../demo_pages/pages/drag_demo_page.dart';
import '../login/login_page.dart';
import '../order/order_page.dart';
import '../setting/setting_page.dart';

class LJRouter {
  static Map<String, WidgetBuilder> routes = {
    orderPage: (context) => OrderPage(),
    dragDemoPage: (context) => DragDemoPage(),
    loginPage: (context) => LoginPage(),
    settingPage: (context) => SettingPage(),

  };

  static List verifyLoginPageList = [
    orderPage,
  ];

  static List fullscreenPageList = [
    loginPage,
  ];

  static String orderPage = 'orderPage';
  static String dragDemoPage = 'dragDemoPage';
  static String loginPage = 'loginPage';
  static String settingPage = 'settingPage';
}
