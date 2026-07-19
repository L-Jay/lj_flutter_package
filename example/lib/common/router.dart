
import 'package:example/demo_pages/pages/router_argument_page.dart';
import 'package:example/mine/about_page.dart';
import 'package:flutter/widgets.dart';
import '../bottom_tabbar.dart';
import '../demo_pages/pages/drag_demo_page.dart';
import '../login/login_page.dart';
import '../order/order_page.dart';
import '../setting/setting_page.dart';

class LJRouter {
  static Map<String, Widget> routes = {
    root: BottomTabbar(),
    loginPage: LoginPage(),

    dragDemoPage: DragDemoPage(),
    argumentPage: RouterArgumentPage(),
    argumentDetailPage: RouterArgumentDetailPage(),

    orderPage: OrderPage(),
    aboutPage: AboutPage(),
    settingPage: SettingPage(),
  };

  static List<String> verifyLoginPageList = [
    orderPage,
  ];

  static List<String> fullscreenPageList = [
    loginPage,
  ];

  static String root = '/';
  static String loginPage = '/loginPage';

  static String dragDemoPage = '/dragDemoPage';

  //GoRouter跳转必须注册到路由
  static String argumentPage = '/argumentPage';
  static String argumentDetailPage = '/argumentDetailPage';

  static String orderPage = '/orderPage';
  static String settingPage = '/settingPage';
  static String aboutPage = '/aboutPage';
}
