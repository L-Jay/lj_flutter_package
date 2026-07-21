import 'package:example/demo_pages/pages/router_argument_page.dart';
import 'package:example/mine/about_page.dart';
import 'package:flutter/widgets.dart';
import 'package:lj_flutter_package/utils/lj_router_manager.dart';
import '../bottom_tabbar.dart';
import '../demo_pages/pages/drag_demo_page.dart';
import '../login/login_page.dart';
import '../order/order_page.dart';
import '../setting/setting_page.dart';

class LJRouter {
  static Map<String, PageBuilder> routes = {
    root: () => const BottomTabbar(),
    loginPage: () => const LoginPage(),

    dragDemoPage: () => const DragDemoPage(),
    argumentPage: () => RouterArgumentPage(),
    argumentDetailPage: () => const RouterArgumentDetailPage(),

    orderPage: () => const OrderPage(),
    aboutPage: () => const AboutPage(),
    settingPage: () => const SettingPage(),
  };

  static List<String> verifyLoginPageList = [orderPage];

  static List<String> fullscreenPageList = [loginPage];

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
