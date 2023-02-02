

import 'package:example/generated/json/base/json_convert_content.dart';
import 'package:example/login/model/user_info_model.dart';

UserInfoModel $UserInfoModelFromJson(Map<String, dynamic> json) {
	final UserInfoModel userInfoModel = UserInfoModel();
	final String? reason = jsonConvert.convert<String>(json['reason']);
	if (reason != null) {
		userInfoModel.reason = reason;
	}
	final int? errorCode = jsonConvert.convert<int>(json['error_code']);
	if (errorCode != null) {
		userInfoModel.errorCode = errorCode;
	}
	final UserInfoResult? result = jsonConvert.convert<UserInfoResult>(json['result']);
	if (result != null) {
		userInfoModel.result = result;
	}
	return userInfoModel;
}

Map<String, dynamic> $UserInfoModelToJson(UserInfoModel entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['reason'] = entity.reason;
	data['error_code'] = entity.errorCode;
	data['result'] = entity.result?.toJson();
	return data;
}

UserInfoResult $UserInfoResultFromJson(Map<String, dynamic> json) {
	final UserInfoResult userInfoResult = UserInfoResult();
	final int? userId = jsonConvert.convert<int>(json['userId']);
	if (userId != null) {
		userInfoResult.userId = userId;
	}
	final String? avatarUrl = jsonConvert.convert<String>(json['avatarUrl']);
	if (avatarUrl != null) {
		userInfoResult.avatarUrl = avatarUrl;
	}
	final String? nikeName = jsonConvert.convert<String>(json['nikeName']);
	if (nikeName != null) {
		userInfoResult.nikeName = nikeName;
	}
	final String? token = jsonConvert.convert<String>(json['token']);
	if (token != null) {
		userInfoResult.token = token;
	}
	return userInfoResult;
}

Map<String, dynamic> $UserInfoResultToJson(UserInfoResult entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['userId'] = entity.userId;
	data['avatarUrl'] = entity.avatarUrl;
	data['nikeName'] = entity.nikeName;
	data['token'] = entity.token;
	return data;
}