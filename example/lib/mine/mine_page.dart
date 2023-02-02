import 'package:example/common/lj_colors.dart';
import 'package:example/common/router.dart';
import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

import '../login/login_manager.dart';

class MinePage extends StatefulWidget {
  const MinePage({Key? key}) : super(key: key);

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  final List<String> _titles = [
    '我的订单',
  ];

  final List<String> _pages = [
    LJRouter.orderPage,
  ];

  @override
  void initState() {
    LJEventBus().on(kLoginEvent, (arg) {
      setState(() {

      });
    });

    LJEventBus().on(kLogoutEvent, (arg) {
      setState(() {

      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          GestureDetector(
            onTap: () {
              RouterManager.pushNamed(context, LJRouter.settingPage);
            },
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUserInfo(context),
          _buildListView(),
        ],
      ),
    );
  }

  ListView _buildListView() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            RouterManager.pushNamed(context, _pages[index]);
          },
          child: Container(
            height: 50,
            color: LJColor.lightBgColor,
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Row(
              children: [
                const Icon(Icons.list, size: 30, color: LJColor.mainColor),
                const SizedBox(width: 10),
                quickText(_titles[index], 14, LJColor.mainColor),
                const Spacer(),
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
    );
  }

  _buildUserInfo(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!LoginManager.isLogin) {
          bool result = await LoginManager.showLogin(context);
          if (result) {
            setState(() {});
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            LJNetworkImage(
                url: LoginManager.userInfoResult?.avatarUrl,
                width: 80,
                height: 80,
                radius: 40),
            const SizedBox(width: 10),
            quickText(
                LoginManager.isLogin
                    ? LoginManager.userInfoResult?.nikeName ?? ''
                    : '未登录',
                16,
                const Color(0xFF333333)),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
