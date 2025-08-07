import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'lj_refresh_view_controller.dart';

class LJRefreshGridView<T> extends StatelessWidget {
  final String? viewTag;
  final EdgeInsetsGeometry? padding;
  final double innerSpace;
  final double itemRatio;
  final int pageSize;
  final Future<List<T>> Function(int page) networkCallback;
  final Widget Function(T model, LJRefreshListViewController controller) itemBuilder;
  final Widget separator;

  const LJRefreshGridView({
    super.key,
    this.viewTag,
    this.padding,
    this.innerSpace = 10,
    required this.itemRatio,
    this.pageSize = 10,
    required this.networkCallback,
    required this.itemBuilder,
    this.separator = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    Get.put<LJRefreshListViewController>(
      LJRefreshListViewController<T>(
        pageSize: pageSize,
        networkCallback: networkCallback,
      ),
      tag: viewTag,
      // permanent: false,
    );

    return GetBuilder<LJRefreshListViewController>(
      tag: viewTag,
      builder: (controller) {
        return SmartRefresher(
          controller: controller.refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: () => controller.fetchData(true),
          onLoading: () => controller.fetchData(false),
          child: GridView.builder(
            padding: padding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: innerSpace,
              crossAxisSpacing: innerSpace,
              childAspectRatio: itemRatio,
            ),
            itemCount: controller.list.length,
            itemBuilder: (context, index) {
              return itemBuilder(controller.list[index], controller);
            },
          ),
        );
      },
    );
  }
}