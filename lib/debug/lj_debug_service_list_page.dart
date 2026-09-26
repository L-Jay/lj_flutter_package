import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../utils/lj_quick_widgets.dart';
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

          // 代码内配置不允许操作，仅本地缓存配置支持左滑复制/删除
          if (index < LJDebugConfig.configList.length) {
            return item;
          }

          return Slidable(
            // 使用内容生成稳定 key，避免删除后后续项索引变化导致 key 复用
            key: ValueKey('local_env_${service.toString()}'),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              dismissible: DismissiblePane(
                onDismissed: () => _deleteLocalService(index),
              ),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context) => _editLocalService(index),
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: '编辑',
                ),
                SlidableAction(
                  onPressed: (BuildContext context) => _copyLocalService(index),
                  backgroundColor: const Color(0xFF1BA3FF),
                  foregroundColor: Colors.white,
                  icon: Icons.copy,
                  label: '复制',
                ),
                SlidableAction(
                  onPressed: (BuildContext context) => _deleteLocalService(index),
                  backgroundColor: const Color(0xFFFF3B30),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: '删除',
                ),
              ],
            ),
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

  // 复制本地缓存环境，将数据传入新增弹窗
  void _copyLocalService(int index) {
    Map<String, String> service = _allServiceList[index];
    _showAddEnvDialog(initialValues: service);
  }

  // 编辑本地缓存环境
  void _editLocalService(int index) {
    Map<String, String> service = _allServiceList[index];
    int localIndex = index - LJDebugConfig.configList.length;
    _showAddEnvDialog(
      title: '编辑环境',
      initialValues: service,
      onSave: (config) {
        LJDebugConfig.localServerList[localIndex] = config;
        LJDebugConfig.cacheLocalServerList();
        // 如果编辑的是当前选中的环境，触发切换回调以刷新当前环境
        if (index == _index) {
          LJDebugConfig.serviceChangeCallback(_allServiceList[index]);
        }
      },
    );
  }

  void _showAddEnvDialog({
    String title = '新增环境',
    Map<String, String>? initialValues,
    void Function(Map<String, String>)? onSave,
  }) {
    List<String> keys = LJDebugConfig.configList.first.keys.toList();

    showDialog<bool>(
      context: context,
      builder: (context) => _AddEnvDialog(
        keys: keys,
        title: title,
        initialValues: initialValues,
        onSave: onSave,
      ),
    ).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }
}

// 新增/编辑环境弹窗
class _AddEnvDialog extends StatefulWidget {
  final List<String> keys;
  final String title;
  final Map<String, String>? initialValues;
  final void Function(Map<String, String>)? onSave;

  const _AddEnvDialog({
    Key? key,
    required this.keys,
    this.title = '新增环境',
    this.initialValues,
    this.onSave,
  }) : super(key: key);

  @override
  State<_AddEnvDialog> createState() => _AddEnvDialogState();
}

class _AddEnvDialogState extends State<_AddEnvDialog> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.keys.length,
      (i) => TextEditingController(
        text: widget.initialValues?[widget.keys[i]] ?? '',
      ),
    );
  }

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
    if (widget.onSave != null) {
      widget.onSave!(config);
    } else {
      LJDebugConfig.localServerList.add(config);
    }
    LJDebugConfig.cacheLocalServerList();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.9;
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: width, maxWidth: 500),
      title: Text(widget.title),
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
