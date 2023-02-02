
import 'package:example/demo_pages/pages/fold_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

import '../common/lj_colors.dart';
import '../home/model/province_model.dart';
import 'pages/corner_half_of_height_page.dart';
import 'pages/drag_demo_page.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage>
    with AutomaticKeepAliveClientMixin {
  final List<String> _titles = [
    '回调模式request',
    'await模式request',
    'String泛型返回JSON字符串',
    '自动根据高度切半圆角',
    '全屏拖拽视图',
    '折叠List',
  ];

  final List<Widget?> _pages = [
    null,
    null,
    null,
    const CornerHalfOfHeightPage(),
    const DragDemoPage(),
    const FoldListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          Widget? page = _pages[index];

          return GestureDetector(
            onTap: () async {
              if (page != null) {
                Navigator.push(context, pageRoute(page));
              } else {
                switch (index) {
                  case 0:
                    _fetchProvince();
                    break;
                  case 1:
                    EasyLoading.show();
                    ProvinceModel model = await LJNetwork.post<ProvinceModel>('/xzqh/query', params: {
                    'key': 'b0f6256515bfc7ae93ab3a48835bf91d',
                    'fid': '130000',
                    });
                    EasyLoading.showToast(model.reason ?? '请求成功');
                    print(model);
                    break;
                  case 2:
                    EasyLoading.show();
                    String jsonStr = await LJNetwork.post<String>('/xzqh/query', params: {
                      'key': 'b0f6256515bfc7ae93ab3a48835bf91d',
                      'fid': '130000',
                    });
                    EasyLoading.showToast(jsonStr);
                    print(jsonStr);
                    break;
                }
              }
            },
            child: Container(
              height: 50,
              color: LJColor.lightBgColor,
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Row(
                children: [
                  quickText(_titles[index], 14, LJColor.mainColor),
                  const Spacer(),
                  if (page != null)
                    const Icon(Icons.arrow_forward_ios,
                        size: 15, color: LJColor.mainColor),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(height: 0.5, color: LJColor.dividerColor);
        },
        itemCount: _titles.length,
      ),
    );
  }

  _fetchProvince() {
    EasyLoading.show();
    LJNetwork.post<ProvinceModel>('/xzqh/query', params: {
      'key': 'b0f6256515bfc7ae93ab3a48835bf91d',
      'fid': '',
    }, successCallback: (ProvinceModel model) {
      EasyLoading.showSuccess(model.reason ?? '请求成功');
      print(model);
      // setState(() {
      //   _provinceModel = data;
      // });
    }, failureCallback: (error) {
      print(error);
      EasyLoading.showSuccess(error.errorMessage);
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
