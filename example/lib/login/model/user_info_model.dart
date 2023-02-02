
import 'dart:convert';

import '../../generated/json/base/json_field.dart';
import '../../generated/json/user_info_model.g.dart';

@JsonSerializable()
class UserInfoModel {

  String? reason;
  @JSONField(name: "error_code")
  int? errorCode;
  UserInfoResult? result;

  UserInfoModel();

  factory UserInfoModel.fromJson(Map<String, dynamic> json) => $UserInfoModelFromJson(json);

  Map<String, dynamic> toJson() => $UserInfoModelToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class UserInfoResult {

  int? userId;
  String? avatarUrl;
  String? nikeName;
  String? token;

  UserInfoResult();

  factory UserInfoResult.fromJson(Map<String, dynamic> json) => $UserInfoResultFromJson(json);

  Map<String, dynamic> toJson() => $UserInfoResultToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}