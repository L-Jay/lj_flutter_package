
import 'package:flutter/material.dart';

import 'lj_debug_network_history_page.dart';
import 'lj_debug_service_list_page.dart';

class LJDebugPage extends StatefulWidget {
  const LJDebugPage({Key? key}) : super(key: key);

  @override
  State<LJDebugPage> createState() => _LJDebugPageState();
}

class _LJDebugPageState extends State<LJDebugPage> {
  final List<String> _titles = [
    '服务器地址',
    '网络请求历史',
  ];

  final List<WidgetBuilder> _builder = [
    (context) => const DebugServiceListPage(),
    (context) => const DebugNetworkHistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('调试工具'),
      ),
      body: ListView.separated(
        itemCount: _titles.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: _builder[index]));
            },
            child: Container(
              height: 55,
              color: Colors.white,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                _titles[index],
                style: const TextStyle(
                  color: Color(0xFF1BA3FF),
                  fontSize: 14,
                ),
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
