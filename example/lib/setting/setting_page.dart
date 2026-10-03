import 'package:example/common/utils.dart';
import 'package:example/login/login_manager.dart';
import 'package:example/setting/about_us_page.dart';
import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';
import 'package:lj_flutter_package/ui_component/lj_image_button.dart';

import '../common/lj_colors.dart';
import '../demo_pages/pages/password_input_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final List<String> _titles = ['支付密码', '关于我们', '当前版本'];

  final List<Widget?> _pages = [
    const PasswordInputPage(),
    const AboutUsPage(),
    null,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Column(
        children: [
          _buildListView(),
          const SizedBox(height: 10),
          if (LoginManager.isLogin)
            LJImageButton(
              width: 200,
              height: 40,
              text: '退出登录',
              textStyle: textStyle(16, Colors.white),
              backgroundColor: LJColor.mainColor,
              onPressed: () {
                showAlert(context, content: '确定退出登录？', submitCallBack: () {
                  LoginManager.logout();
                  setState(() {});
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 20),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        Widget? page = _pages[index];

        return GestureDetector(
          onTap: () {
            if (page != null) {
              RouterManager.pushPage(page);
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
                if (page == null)
                  quickText(LJUtil.packageInfo.version, 14, LJColor.mainColor),
                if (page == null) const SizedBox(width: 10),
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
}
