import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ui_component/lj_drag_container.dart';
import '../utils/lj_quick_widgets.dart';
import '../utils/lj_router_manager.dart';
import '../utils/lj_util.dart';
import 'lj_debug_network_history_page.dart';
import 'lj_debug_page.dart';

typedef LJServiceChangeCallback = void Function(Map<String, String> map);

class LJDebugConfig {
  /*务必第一个配置正式环境，release版本默认读取第一个配置项*/
  static late List<Map<String, String>> configList;

  // 本地缓存的环境配置 key
  static const String kLocalServerListKey = 'localServerList';

  // 本地缓存的环境配置，无缓存时为空数组（不为 null）
  static List<Map<String, String>> localServerList = [];

  static bool _isLocalServerListInited = false;

  // 从本地缓存读取环境配置并初始化 localServerList
  static void initLocalServerList() {
    if (_isLocalServerListInited) return;
    _isLocalServerListInited = true;
    final String? jsonStr = LJUtil.preferences.getString(kLocalServerListKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      localServerList = [];
      return;
    }
    try {
      localServerList = (jsonDecode(jsonStr) as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    } catch (e) {
      localServerList = [];
    }
  }

  // 代码内配置 + 本地缓存配置 的合并列表
  static List<Map<String, String>> get allConfigList =>
      [...configList, ...localServerList];

  // 缓存 localServerList 到本地
  static void cacheLocalServerList() {
    LJUtil.preferences.setString(
        kLocalServerListKey, jsonEncode(localServerList));
  }

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

  static bool show = false;
  static bool _isGet = false;

  static set serviceChangeCallback(LJServiceChangeCallback callback) {
    int index;
    if (kDebugMode || show) {
      initLocalServerList();
      index = LJUtil.preferences.getInt('LJDebugIndex') ?? 0;
    } else {
      index = 0;
    }

    // 索引指向合并列表（代码配置 + 本地缓存配置），越界时回退到第一个环境
    List<Map<String, String>> allList = allConfigList;
    if (allList.isEmpty) {
      throw StateError('LJDebugConfig.configList 不能为空');
    }
    if (index < 0 || index >= allList.length) {
      index = 0;
      LJUtil.preferences.setInt('LJDebugIndex', 0);
    }
    callback(allList[index]);
    _serviceChangeCallback = callback;

    if (!kDebugMode) return;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BuildContext? finalContext;
      if (Get.overlayContext != null) {
        finalContext = Get.overlayContext;
        _isGet = true;
      } else {
        finalContext = context ??
            RouterManager.navigatorKey.currentState?.overlay?.context;
      }

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
        offset:
            Offset(size.width - 56 - 10, size.height - 56 - 56 - 10 - bottom),
        adsorption: LJDragAdsorption.all,
        onTap: () {
          if (_isGet) {
            Get.to(() => const DebugNetworkHistoryPage());
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DebugNetworkHistoryPage(),
              ),
            );
          }
        },
        child: quickText(title, 18, Colors.white),
      );
    });

    return Overlay.of(context)?.insert(_entry);
  }
}
