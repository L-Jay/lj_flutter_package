import 'package:flutter/material.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LJRefreshListView<T> extends StatelessWidget {
  final String? viewTag;
  final EdgeInsetsGeometry? padding;
  final int pageSize;
  final Future<List<T>> Function(int page) networkCallback;
  final Widget Function(T model, LJRefreshListViewController controller) itemBuilder;
  final Widget separator;

  const LJRefreshListView({
    super.key,
    this.viewTag,
    this.padding,
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
          child: ListView.separated(
            padding: padding,
            itemCount: controller.list.length,
            itemBuilder: (context, index) {
              return itemBuilder(controller.list[index], controller);
            },
            separatorBuilder: (BuildContext context, int index) => separator,
          ),
        );
      },
    );
  }
}

class LJRefreshListViewController<T> extends GetxController {
  final int pageSize;
  final Future<List<T>> Function(int page) networkCallback;

  LJRefreshListViewController({
    required this.pageSize,
    required this.networkCallback,
  });

  final RefreshController refreshController = RefreshController();

  List<T> list = [];
  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();

    fetchData(true);
  }

  fetchData(bool isRefresh) async {
    if (isRefresh) {
      _currentPage = 1;
      list.clear();
    }

    List<T> resultList = await networkCallback(_currentPage);
    refreshController.refreshCompleted();
    refreshController.loadComplete();

    if (resultList.isNotEmpty) {
      if (resultList.length < pageSize) {
        refreshController.loadNoData();
      } else {
        _currentPage++;
      }

      list.addAll(resultList);
      update();
    }else {
      refreshController.loadNoData();
    }
  }
}