import 'package:flutter/material.dart';

import '../utils/lj_define.dart';
import '../utils/lj_util.dart';
import 'lj_debug_config.dart';

class DebugServiceListPage extends StatefulWidget {
  const DebugServiceListPage({Key? key}) : super(key: key);

  @override
  State<DebugServiceListPage> createState() => _DebugServiceListPageState();
}

class _DebugServiceListPageState extends State<DebugServiceListPage> {
  int _index = LJUtil.preferences.getInt('LJDebugIndex') ?? 0;

  // 代码内配置 + 本地缓存配置（统一走 LJDebugConfig 的合并列表）
  List<Map<String, String>> get _allServiceList => LJDebugConfig.allConfigList;

  @override
  void initState() {
    super.initState();
    LJDebugConfig.initLocalServerList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F9),
      appBar: AppBar(
        title: const Text('环境列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEnvDialog,
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _allServiceList.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, String> service = _allServiceList[index];

          Widget item = GestureDetector(
            onTap: () {
              LJDebugConfig.serviceChangeCallback(service);
              LJUtil.preferences.setInt('LJDebugIndex', index);
              setState(() {
                _index = index;
              });
            },
            child: Container(
              color: Colors.white,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: service
                          .map((key, value) => MapEntry(
                              key,
                              Container(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: quickRichText([
                                    key,
                                    '：',
                                    value,
                                  ], [
                                    const TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                    const TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                    const TextStyle(
                                        color: Color(0xFF666666), fontSize: 14)
                                  ]))))
                          .values
                          .toList(),
                    ),
                  ),
                  if (index == _index)
                    const Icon(
                      Icons.done,
                      color: Color(0xFF1BA3FF),
                    ),
                ],
              ),
            ),
          );

          // 代码内配置不允许删除，仅本地缓存配置支持左滑删除
          if (index < LJDebugConfig.configList.length) {
            return item;
          }

          return Dismissible(
            // 使用内容生成稳定 key，避免删除后后续项索引变化导致 key 复用
            key: ValueKey('local_env_${service.toString()}'),
            direction: DismissDirection.endToStart,
            // endToStart 方向下不会展示，但 Flutter 要求 secondaryBackground
            // 存在时 background 必须同时存在，否则会触发断言
            background: Container(color: const Color(0xFFFF3B30)),
            secondaryBackground: Container(
              color: const Color(0xFFFF3B30),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _deleteLocalService(index),
            child: item,
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            indent: 15,
          );
        },
      ),
    );
  }

  // 删除本地缓存环境，并更新本地缓存
  void _deleteLocalService(int index) {
    int localIndex = index - LJDebugConfig.configList.length;
    LJDebugConfig.localServerList.removeAt(localIndex);
    LJDebugConfig.cacheLocalServerList();

    if (index == _index) {
      // 删除的是当前选中的 item，切换到第一个环境
      _index = 0;
      LJUtil.preferences.setInt('LJDebugIndex', _index);
      LJDebugConfig.serviceChangeCallback(_allServiceList[_index]);
    } else if (index < _index) {
      // 删除项位于选中项之前，选中索引前移一位
      _index -= 1;
      LJUtil.preferences.setInt('LJDebugIndex', _index);
    }
    setState(() {});
  }

  void _showAddEnvDialog() {
    List<String> keys = LJDebugConfig.configList.first.keys.toList();

    showDialog<bool>(
      context: context,
      builder: (context) => _AddEnvDialog(keys: keys),
    ).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }
}

// 新增环境弹窗
class _AddEnvDialog extends StatefulWidget {
  final List<String> keys;

  const _AddEnvDialog({Key? key, required this.keys}) : super(key: key);

  @override
  State<_AddEnvDialog> createState() => _AddEnvDialogState();
}

class _AddEnvDialogState extends State<_AddEnvDialog> {
  late final List<TextEditingController> _controllers =
      List.generate(widget.keys.length, (_) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onSave() {
    Map<String, String> config = {};
    for (int i = 0; i < widget.keys.length; i++) {
      config[widget.keys[i]] = _controllers[i].text;
    }
    LJDebugConfig.localServerList.add(config);
    LJDebugConfig.cacheLocalServerList();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.9;
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: width, maxWidth: 500),
      title: const Text('新增环境'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            widget.keys.length,
            (index) => _EnvInputItem(
              title: widget.keys[index],
              controller: _controllers[index],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _onSave,
          child: const Text('保存'),
        ),
      ],
    );
  }
}

// 弹窗输入项封装：左边 title，右边输入框
class _EnvInputItem extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  const _EnvInputItem({Key? key, required this.title, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: quickText(title, 14, const Color(0xFF333333)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '请输入',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
