import 'package:example/common/api_url.dart';
import 'package:example/common/router.dart';
import 'package:example/login/model/user_info_model.dart';
import 'package:lj_flutter_package/lj_flutter_package.dart';

const String kLoginEvent = 'LoginEvent';
const String kLogoutEvent = 'LogoutEvent';

class UserService extends GetxService {
  static UserService get to => Get.find();

  /// 用户信息，登录后由 /user/info 拉取
  final Rx<UserInfoResult?> userInfoResult = Rx<UserInfoResult?>(null);

  bool get isLogin => userInfoResult.value != null;

  String get token => userInfoResult.value?.token ?? '';

  /*当前登录的手机号（仅 mock 使用）*/
  String? loginPhone;

  /*当前登录的验证码（仅 mock 使用）*/
  String? loginCode;

  /// 登录成功：保存 token 并拉取用户信息
  void loginSuccess(UserInfoResult result) {
    String? currentToken = result.token;
    userInfoResult.value = result;
    LJNetwork.headers.addAll({'Authorization': currentToken ?? ''});
    fetchUserInfo();
  }

  /// 获取用户信息
  void fetchUserInfo() {
    String? currentToken = token;
    LJNetwork.post<UserInfoModel>(
      ApiUrl.userInfo,
      successCallback: (UserInfoModel model) {
        UserInfoResult? result = model.result;
        if (result != null) {
          // /user/info 不返回 token，这里保留登录时的 token
          result.token = currentToken;
          userInfoResult.value = result;
          LJEventBus.emit(kLoginEvent);
        }
      },
    );
  }

  void logout() {
    userInfoResult.value = null;

    LJNetwork.headers.remove('Authorization');
    LJEventBus.emit(kLogoutEvent);
  }

  Future<bool> showLogin() async {
    if (isLogin) return true;

    bool? result = await RouterManager.pushNamed(LJRouter.loginPage);

    if (result == true) {
      LJEventBus.emit(kLoginEvent);
    }

    return result ?? false;
  }
}
