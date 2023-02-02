import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../ui_component/lj_drag_container.dart';
import '../utils/lj_define.dart';
import '../utils/lj_router_manager.dart';
import '../utils/lj_util.dart';
import 'lj_debug_page.dart';

typedef LJServiceChangeCallback = void Function(Map<String, String> map);

class LJDebugConfig {
  /*务必第一个配置正式环境，release版本默认读取第一个配置项*/
  static late List<Map<String, String>> configList;

  /*
  第一次赋值会主动调用并返回上次选择的环境
  release下直接返回第一个环境
  * */
  static late LJServiceChangeCallback _serviceChangeCallback;

  // 显示debug控件context，如果在MaterialApp中指定了navigatorKey，则不需要赋值
  static BuildContext? context;
  // static set context(context) {
  //   _context = context;
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     _insertOverlay(context, 'LJ');
  //   });
  // }

  static set serviceChangeCallback(LJServiceChangeCallback callback) {
    int index;
    if (kDebugMode) {
      index = LJUtil.preferences.getInt('LJDebugIndex') ?? 0;
    } else {
      index = 0;
    }
    callback(configList[index]);
    _serviceChangeCallback = callback;

    if (!kDebugMode) return;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var finalContext = context ?? RouterManager.navigatorKey.currentState?.overlay?.context;
      if (finalContext != null) _insertOverlay(finalContext, 'LJ');
    });
  }

  static LJServiceChangeCallback get serviceChangeCallback =>
      _serviceChangeCallback;

  static late OverlayEntry _entry;

  static void _insertOverlay(BuildContext context, String title) {
    _entry = OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      final bottom = MediaQuery.of(context).padding.bottom;
      return LJDragContainer(
        offset: Offset(size.width-56-10, size.height-56-56-10-bottom),
        adsorption: LJDragAdsorption.all,
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LJDebugPage()));
        },
        child: quickText(title, 18, Colors.white),
      );
    });

    return Overlay.of(context)?.insert(_entry);
  }
}
