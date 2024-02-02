import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'lj_util.dart';

/*请求成功回调*/
typedef LJNetworkSuccessCallback<T> = void Function(T data);

/*请求失败回调*/
typedef LJNetworkFailureCallback = void Function(LJNetworkError error);

typedef LJNetworkJsonParse<T> = T Function<T>(dynamic data);

typedef LJNetworkStatusCallback = void Function(LJNetworkStatus status);

enum LJNetworkStatus { wifi, mobile, none }

class LJNetwork {
  static final Dio dio = _createDio();

  /*baseUrl*/
  static late String _baseUrl;

  static set baseUrl(url) {
    _baseUrl = url;
    dio.options.baseUrl = url;
  }

  static String get baseUrl => _baseUrl;

  /*headers*/
  static Map<String, String> headers = {};

  /*value*/
  static Map<String, dynamic> defaultParams = {};

  /*状态码key*/
  static late String codeKey;

  /*请求成功状态码，默认200*/
  static int successCode = 200;

  /*状态描述key*/
  static late String messageKey;

  /*捕获全部请求错误*/
  static LJNetworkFailureCallback? handleAllFailureCallBack;

  static LJNetworkJsonParse? jsonParse;

  /*请求CancelToken Map*/
  static final Map<String, CancelToken> _cancelTokens = {};

  /*
  拦截请求参数，可对参数进行处理并返回给原位置
  path:请求路径
  requestParams：请求参数
  */
  static Map<String, dynamic> Function(
      String path, Map<String, dynamic>? requestParams)? handleRequestParams;

  /*
  拦截响应体，此拦截只有请求成功（status code为200~299）的情况下响应
  path:请求路径
  responseData：原始data
  */
  static Map<String, dynamic> Function(
      String path, Map<String, dynamic> responseData)? handleResponseData;

  /*
  模拟响应，直接阻断真实网络请求并返回数据
  path:请求路径
  requestParams：请求参数，可以判断请求参数返回对应的响应体
  */
  static Future<Map<String, dynamic>> Function(
      String path, Map<String, dynamic>? requestParams)? mockResponse;

  /*需要mock的请求路径数组*/
  static Set<String> mockPathSet = <String>{};

  static Dio _createDio() {
    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: 15 * 1000,
      receiveTimeout: 15 * 1000,
    ));

    if (kDebugMode) {
      dio.interceptors
          .add(LogInterceptor(requestBody: true, responseBody: true));
    }

    return dio;
  }

  /*当前网络是否可用*/
  static bool? networkActive;

  static final Map<dynamic, StreamSubscription> _networkStatusSubscriptionMap =
      {};

  /*
  监控网络状态
  context为key，取消监控使用
  */
  static handleNetworkStatus(
      dynamic context, LJNetworkStatusCallback callback) {
    // ignore: cancel_subscriptions
    StreamSubscription<ConnectivityResult> connectivitySubscription =
        Connectivity()
            .onConnectivityChanged
            .listen((ConnectivityResult result) {
      networkActive = result != ConnectivityResult.none;

      switch (result) {
        case ConnectivityResult.wifi:
          callback(LJNetworkStatus.wifi);
          break;
        case ConnectivityResult.mobile:
          callback(LJNetworkStatus.mobile);
          break;
        case ConnectivityResult.none:
        case ConnectivityResult.bluetooth:
        case ConnectivityResult.ethernet:
          callback(LJNetworkStatus.none);
          break;
        case ConnectivityResult.vpn:
          break;
      }
    });

    _networkStatusSubscriptionMap[context] = connectivitySubscription;
  }

  /*取消监控网络状态*/
  static cancelHandleNetworkStatus(dynamic context) {
    _networkStatusSubscriptionMap[context]?.cancel();
    _networkStatusSubscriptionMap.remove(context);
  }

  /*
  get请求
  path如果包含http/https,忽略baseUrl
  path作为取消网络请求的标识，如果为空，使用全局取消cancelToken
  * */
  static Future<dynamic> get<T>(String path,
      {Map<String, dynamic>? params,
      Map<String, dynamic>? addHeaders,
      LJNetworkSuccessCallback<T>? successCallback,
      LJNetworkFailureCallback? failureCallback}) async {
    return _request<T>(path,
        isGet: true,
        params: params,
        addHeaders: addHeaders,
        successCallback: successCallback,
        failureCallback: failureCallback);
  }

  /*
  post请求
  path如果包含http/https,忽略baseUrl
  path作为取消网络请求的标识，如果为空，使用全局取消cancelToken
  * */
  static Future<dynamic> post<T>(String path,
      {Map<String, dynamic>? params,
      Map<String, dynamic>? data,
      Map<String, dynamic>? addHeaders,
      LJNetworkSuccessCallback<T>? successCallback,
      LJNetworkFailureCallback? failureCallback}) async {
    return _request<T>(path,
        isPost: true,
        params: params,
        data: data,
        addHeaders: addHeaders,
        successCallback: successCallback,
        failureCallback: failureCallback);
  }

  static Future<dynamic> put<T>(String path,
      {Map<String, dynamic>? params,
      Map<String, dynamic>? data,
      Map<String, dynamic>? addHeaders,
      LJNetworkSuccessCallback<T>? successCallback,
      LJNetworkFailureCallback? failureCallback}) async {
    return _request<T>(path,
        isPut: true,
        params: params,
        data: data,
        addHeaders: addHeaders,
        successCallback: successCallback,
        failureCallback: failureCallback);
  }

  /*
  post请求
  path如果包含http/https,忽略baseUrl
  path作为取消网络请求的标识，如果为空，使用全局取消cancelToken
  * */
  static Future<dynamic> delete<T>(String path,
      {Map<String, dynamic>? params,
      Map<String, dynamic>? addHeaders,
      LJNetworkSuccessCallback<T>? successCallback,
      LJNetworkFailureCallback? failureCallback}) async {
    return _request<T>(
      path,
      params: params,
      data: null,
      isDelete: true,
      addHeaders: addHeaders,
      successCallback: successCallback,
      failureCallback: failureCallback,
    );
  }

  static Future<dynamic> _request<T>(
    String path, {
    bool isPost = false,
    bool isGet = false,
    bool isDelete = false,
    bool isPut = false,
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    Map<String, dynamic>? addHeaders,
    LJNetworkSuccessCallback<T>? successCallback,
    LJNetworkFailureCallback? failureCallback,
  }) async {
    // 未获取网络状态初次获取
    // if (networkActive == null) {
    //   var result = await Connectivity().checkConnectivity();
    //   networkActive = result != ConnectivityResult.none;
    // }
    //
    // if (!networkActive) {
    //   failureCallback?.call((LJNetworkError(444, '网络异常，请检查网络设置')));
    //   return;
    // }

    Completer completer = Completer<dynamic>();

    NetworkHistoryModel historyModel = NetworkHistoryModel();

    try {
      /*header*/
      Map<String, dynamic> headers = {};
      headers.addAll(headers);
      if (addHeaders != null) headers.addAll(addHeaders);
      dio.options.headers = headers;

      /*添加默认请求参数*/
      if (isGet || isDelete) {
        params?.addAll(defaultParams);

        /*拦截请求参数*/
        if (handleRequestParams != null) {
          params = handleRequestParams!(path, params);
        }
      } else {
        data?.addAll(defaultParams);

        /*拦截请求参数*/
        if (handleRequestParams != null) {
          data = handleRequestParams!(path, data);
        }
      }

      /*cancelToken*/
      CancelToken cancelToken = CancelToken();
      _cancelTokens[path] = cancelToken;

      // request
      late Response response;
      if (kDebugMode && mockResponse != null && mockPathSet.contains(path)) {
        Map<String, dynamic> responseData =
            await mockResponse!(path, data ?? params);
        response = Response(
          requestOptions: RequestOptions(path: path),
          data: responseData,
          statusCode: 200,
          statusMessage: '$path模拟请求成功',
        );
      } else if (isPost) {
        historyModel.method = 'post';

        response = await dio.post(
          path,
          queryParameters: params,
          data: data,
          cancelToken: cancelToken,
        );
      } else if (isGet) {
        historyModel.method = 'get';

        response = await dio.get(
          path,
          queryParameters: params,
          cancelToken: cancelToken,
        );
      } else if (isPut) {
        historyModel.method = 'put';

        response = await dio.put(
          path,
          queryParameters: params,
          data: data,
          cancelToken: cancelToken,
        );
      } else if (isDelete) {
        historyModel.method = 'delete';

        response = await dio.delete(
          path,
          queryParameters: params,
          cancelToken: cancelToken,
        );
      }

      if (kDebugMode) {
        historyModel.title = path;
        historyModel.url = response.realUri.toString();
        historyModel.headers = headers;
        historyModel.params = params ?? (data is Map ? data : null);
        historyModel.responseHeaders = response.headers.map;
        historyModel.jsonResult = jsonEncode(response.data);

        historyList.insert(0, historyModel);
      }

      // 删除本次请求的cancelToken
      _cancelTokens.remove(path);

      if (handleResponseData != null) {
        response.data = handleResponseData!(path, response.data);
      }

      if (response.data is String) {
        response.data = jsonDecode(response.data);
      }

      int? code = response.data[codeKey];

      /*请求数据成功*/
      if (code == null || code == successCode) {
        if (T == dynamic || T.toString().contains('?')) {
          successCallback?.call(response.data);
          completer.complete(response.data);
        } else if (T.toString() == 'String') {
          String jsonString = jsonEncode(response.data);
          successCallback?.call(jsonString as T);
          completer.complete(jsonString);
        } else {
          if (jsonParse != null) {
            T t = jsonParse!<T>(response.data);

            successCallback?.call(t);
            completer.complete(t);
          } else {
            successCallback?.call(response.data);
            completer.complete(response.data);
          }
        }
      } else {
        /*请求数据发生错误*/
        LJNetworkError error = LJNetworkError(code, response.data[messageKey]);

        failureCallback?.call(error);

        handleAllFailureCallBack?.call(error);

        completer.complete(error);
      }
    } on DioError catch (error) {
      LJNetworkError finalError;
      int? errorCode =
          error.response?.data is Map ? error.response?.data[codeKey] : null;
      String? message =
          error.response?.data is Map ? error.response?.data[messageKey] : null;

      if (errorCode != null && message != null) {
        historyModel.errorCode = errorCode.toString();
        historyModel.errorMsg = message;

        finalError = LJNetworkError(errorCode, message);

        failureCallback?.call(finalError);

        handleAllFailureCallBack?.call(finalError);
      } else {
        switch (error.type) {
          case DioErrorType.connectTimeout:
          case DioErrorType.receiveTimeout:
          case DioErrorType.sendTimeout:
            errorCode = 504;
            message = LJUtil.isEnglish ? 'Network exception' : '网络连接超时，请检查网络设置';
            break;
          case DioErrorType.response:
            errorCode = 404;
            message = LJUtil.isEnglish ? 'Network exception' : '服务器异常，请稍后重试！';
            break;
          case DioErrorType.other:
            errorCode = 500;
            message = LJUtil.isEnglish ? 'Network exception' : '网络异常，请稍后重试！';
            break;

          case DioErrorType.cancel:
            // TODO: Handle this case.
            break;
        }
        /*请求数据发生错误*/
        finalError = LJNetworkError(errorCode!, message!);

        failureCallback?.call(finalError);

        handleAllFailureCallBack?.call(finalError);

        historyModel.responseHeaders = error.response?.headers.map;
        historyModel.errorCode = error.response?.statusCode?.toString();
        historyModel.errorMsg = error.response?.statusMessage;

        if (kDebugMode) historyList.insert(0, historyModel);
      }

      completer.complete(finalError);
    }

    return completer.future;
  }

  static Future download({
    required String url,
    required String savePath,
    ProgressCallback? onReceiveProgress,
    Function? error,
  }) {
    return dio
        .download(
          url,
          savePath,
          onReceiveProgress: onReceiveProgress,
          options: Options(receiveTimeout: 5 * 60 * 1000),
        )
        .catchError(error as Function);
  }

  /*
  取消请求
  path为空时，取消所有path为空的请求
  */
  static cancel({String? path}) {
    if (path != null) {
      CancelToken? cancelToken = _cancelTokens[path];
      cancelToken?.cancel();
      _cancelTokens.remove(path);
      if (kDebugMode) {
        print('========取消请求$path');
      }
    } else {
      _cancelTokens.forEach((path, cancelToken) {
        cancelToken.cancel();
        if (kDebugMode) {
          print('========取消请求$path');
        }
      });

      if (kDebugMode) {
        print('========取消了所有请求========');
      }
      _cancelTokens.clear();
    }
  }

  /*------ Debug -------*/
  static List<NetworkHistoryModel> historyList = [];
}

class LJNetworkError {
  LJNetworkError(this.errorCode, this.errorMessage);

  int errorCode;
  String errorMessage;
}

class NetworkHistoryModel {
  String? title;
  String? url;
  String? method;
  Map? headers;
  Map? params;
  Map<String, List<String>>? responseHeaders;
  String? jsonResult;
  String? errorCode;
  String? errorMsg;

  @override
  String toString() {
    return '{"title":"${title ?? ''}","url":"${url ?? ''}","method":"${method ?? ''}","headers":"${headers?.toString() ?? ''}","params":"${params?.toString() ?? ''}","responseHeaders":"${responseHeaders?.toString() ?? ''}","jsonResult":${jsonResult ?? ''},"errorCode":"${errorCode ?? ''}","errorMsg":"${errorMsg ?? ''}"}';
  }
}
