import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_view/flutter_json_view.dart';

import '../utils/lj_network.dart';

class DebugNetworkHistoryDetailPage extends StatefulWidget {
  final NetworkHistoryModel historyModel;

  const DebugNetworkHistoryDetailPage({Key? key, required this.historyModel})
      : super(key: key);

  @override
  State<DebugNetworkHistoryDetailPage> createState() =>
      _DebugNetworkHistoryDetailPageState();
}

class _DebugNetworkHistoryDetailPageState
    extends State<DebugNetworkHistoryDetailPage> {
  _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Center(child: Text(message)),
      duration: const Duration(seconds: 1), // 显示时长
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F9),
      appBar: AppBar(
        title: Text(widget.historyModel.title ?? ''),
        actions: [
          GestureDetector(
            onTap: () {
              String value = widget.historyModel.toString();
              Clipboard.setData(ClipboardData(text: value));

              _showSnackBar(context, '复制成功');
            },
            child: const Center(child: Text('Copy All')),
          ),
          IconButton(
              icon: const Icon(
                Icons.copy,
              ),
              onPressed: () {
                String message = '复制失败';
                if (widget.historyModel.jsonResult?.isNotEmpty == true) {
                  Clipboard.setData(
                    ClipboardData(text: widget.historyModel.jsonResult!),
                  );
                  message = '复制成功';
                }

                _showSnackBar(context, message);
              }),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.historyModel.url ?? '',
                  style: const TextStyle(
                    color: Color(0xFF1BA3FF),
                    fontSize: 15,
                  ),
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  color: const Color(0xFF717171),
                ),
                Text(
                  widget.historyModel.method ?? '',
                  style: const TextStyle(
                    color: Color(0xFF1BA3FF),
                    fontSize: 15,
                  ),
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  color: const Color(0xFF717171),
                ),
                ...mapWidget(widget.historyModel.headers ?? {}),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  color: const Color(0xFF717171),
                ),
                ...mapWidget(widget.historyModel.params ?? {}),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  color: const Color(0xFF717171),
                ),
                ...mapWidget(widget.historyModel.responseHeaders ?? {}),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  color: const Color(0xFF717171),
                ),
                if (widget.historyModel.errorCode == null)
                  JsonView.string(widget.historyModel.jsonResult ?? ''),
                if (widget.historyModel.errorCode != null)
                  Text(
                    '${widget.historyModel.errorCode ?? ''}   ${widget.historyModel.errorMsg ?? ''}',
                    style: const TextStyle(
                      color: Color(0xFF1BA3FF),
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> mapWidget(Map map) {
    List<Widget> headerWidget = [];
    map.forEach((key, value) {
      headerWidget.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '$key : $value',
            style: const TextStyle(
              color: Color(0xFF1BA3FF),
              fontSize: 15,
            ),
          ),
        ),
      );
    });

    return headerWidget;
  }
}
