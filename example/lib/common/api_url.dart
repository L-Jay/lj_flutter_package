
class ApiUrl {
  /// 生产
  static const productUrl = 'http://apis.juhe.cn';
  /// 开发
  static const devUrl = 'https://www.dev.com';

  ///验证码
  static String sendCode = '/login/fetchCode';
  ///手机号登录
  static String mobileLogin = '/login';
  ///用户信息
  static String userInfo = '/user/info';
}