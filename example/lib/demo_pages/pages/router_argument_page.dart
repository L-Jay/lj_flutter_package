import 'dart:math';

import 'package:example/common/router.dart';
import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

import '../../common/lj_colors.dart';

class RouterArgumentPage extends StatelessWidget {
  RouterArgumentPage({super.key});

  final String stringArg = 'test';
  final int intArg = 666;
  final Map<String, dynamic> mapArg = {'key': 'value'};
  final Product productArg = Product(id: '1', name: 'test');

  final _random = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Router Argument Page')),
      body: quickContainer(
        padding: EdgeInsets.all(15),
        color: Colors.white,
        circular: 8,
        child: Column(
          children: [
            quickText(RouterManager.routerType.name, 16, LJColor.mainColor),
            SizedBox(height: 44),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                _random.value = await RouterManager.pushNamed(
                  LJRouter.argumentDetailPage,
                  arguments: stringArg,
                );
              },
              child: SizedBox(
                height: 44,
                child: quickText('String - $stringArg', 14, LJColor.mainColor),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                _random.value = await RouterManager.pushNamed(
                  LJRouter.argumentDetailPage,
                  arguments: intArg,
                );
              },
              child: SizedBox(
                height: 44,
                child: quickText('int - $intArg', 14, LJColor.mainColor),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                _random.value = await RouterManager.pushNamed(
                  LJRouter.argumentDetailPage,
                  arguments: mapArg,
                );
              },
              child: SizedBox(
                height: 44,
                child: quickText('Map - $mapArg', 14, LJColor.mainColor),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                _random.value = await RouterManager.pushNamed(
                  LJRouter.argumentDetailPage,
                  arguments: productArg,
                );
              },
              child: SizedBox(
                height: 44,
                child: quickText(
                  'Product - ${productArg.id}, ${productArg.name}',
                  14,
                  LJColor.mainColor,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                RouterManager.pushNamed('/404page');
              },
              child: SizedBox(
                height: 44,
                child: quickText('push到404页面', 14, LJColor.mainColor),
              ),
            ),
            SizedBox(height: 44),
            Obx(() => quickText('返回的随机数: $_random', 14, LJColor.mainColor)),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String id;
  final String name;

  Product({required this.id, required this.name});
}

class RouterArgumentDetailPage extends StatelessWidget {
  const RouterArgumentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Router Argument Detail Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 5,
          children: [
            quickText(
              'router type: ${RouterManager.routerType.name}',
              14,
              LJColor.mainColor,
            ),
            quickText('argument: ${context.argument}', 14, LJColor.mainColor),
            quickText(
              'argumentMap: ${context.argumentMap}',
              14,
              LJColor.mainColor,
            ),
            quickText(
              'valueForKey: ${context.argumentForKey('key')}',
              14,
              LJColor.mainColor,
            ),
            SizedBox(height: 88),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                RouterManager.pop(Random().nextInt(100));
              },
              child: quickText('返回一个随机的数字吧', 14, LJColor.mainColor),
            ),
          ],
        ),
      ),
    );
  }
}
