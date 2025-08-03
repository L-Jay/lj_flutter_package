
import 'package:example/home/home_page.dart';
import 'package:example/mine/mine_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lj_flutter_package/widgets/double_pop_widget.dart';

import 'demo_pages/demo_page.dart';

class BottomTabbar extends StatefulWidget {
  const BottomTabbar({Key? key}) : super(key: key);

  @override
  State<BottomTabbar> createState() => _BottomTabbarState();
}

class _BottomTabbarState extends State<BottomTabbar> {

  final PageController _pageController = PageController();

  final ValueNotifier<int> _indexValueNotifier = ValueNotifier(0);

  final List<Widget> _pages = const [
    HomePage(),
    DemoPage(),
    MinePage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DoublePopWidget(
      firstCallBack: () {
        EasyLoading.showToast('再按一次退出');
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ValueListenableBuilder(
            valueListenable: _indexValueNotifier,
            builder: (BuildContext context, int value, Widget? child) {
              return BottomNavigationBar(
                currentIndex: value,
                selectedFontSize: 14,
                unselectedFontSize: 14,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: '首页',
                    tooltip: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    label: 'Demo',
                    tooltip: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people),
                    label: '我的',
                    tooltip: '',
                  ),
                ],
                onTap: (index) {
                  _pageController.jumpToPage(index);
                  _indexValueNotifier.value = index;
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
