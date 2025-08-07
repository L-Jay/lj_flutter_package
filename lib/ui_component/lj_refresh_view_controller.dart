import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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