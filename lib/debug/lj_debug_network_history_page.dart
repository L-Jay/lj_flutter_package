import 'package:flutter/material.dart';
import 'package:lj_flutter_package/debug/lj_debug_config.dart';
import 'package:lj_flutter_package/debug/lj_debug_page.dart';
import '../utils/lj_network.dart';
import 'lj_debug_network_history_detail_page.dart';
import 'lj_debug_service_list_page.dart';

class DebugNetworkHistoryPage extends StatefulWidget {
  const DebugNetworkHistoryPage({Key? key}) : super(key: key);

  @override
  State<DebugNetworkHistoryPage> createState() =>
      _DebugNetworkHistoryPageState();
}

class _DebugNetworkHistoryPageState extends State<DebugNetworkHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F9),
      appBar: AppBar(
        title: const Text('请求历史'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.settings,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DebugServiceListPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
            ),
            onPressed: () {
              setState(() {
                LJNetwork.historyList.clear();
              });
            },
          ),
        ],
      ),
      body: _buildListView(),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: LJNetwork.historyList.length,
      itemBuilder: (BuildContext context, int index) {
        NetworkHistoryModel model = LJNetwork.historyList[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DebugNetworkHistoryDetailPage(
                    historyModel: model,
                  ),
                ));
          },
          child: Container(
            height: 55,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    model.title ?? '',
                    style: const TextStyle(
                      color: Color(0xFF1BA3FF),
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  width: 10,
                ),
                Text(
                  model.method ?? '',
                  style: const TextStyle(
                    color: Color(0xFF1BA3FF),
                    fontSize: 15,
                  ),
                ),
                const Icon(
                  Icons.navigate_next,
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
    );
  }
}
