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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F9),
      appBar: AppBar(
        title: const Text('服务器列表'),
      ),
      body: ListView.separated(
        itemCount: LJDebugConfig.configList.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, String> service = LJDebugConfig.configList[index];

          return GestureDetector(
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
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            indent: 15,
          );
        },
      ),
    );
  }
}
