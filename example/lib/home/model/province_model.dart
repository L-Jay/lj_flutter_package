
import 'dart:convert';

import 'package:example/generated/json/base/json_field.dart';
import 'package:example/generated/json/province_model.g.dart';

@JsonSerializable()
class ProvinceModel {

	String? reason;
	List<ProvinceResult>? result;
	@JSONField(name: "error_code")
	int? errorCode;
  
  ProvinceModel();

  factory ProvinceModel.fromJson(Map<String, dynamic> json) => $ProvinceModelFromJson(json);

  Map<String, dynamic> toJson() => $ProvinceModelToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class ProvinceResult {

	String? id;
	String? name;
	String? fid;
	@JSONField(name: "level_id")
	String? levelId;
  
  ProvinceResult();

  factory ProvinceResult.fromJson(Map<String, dynamic> json) => $ProvinceResultFromJson(json);

  Map<String, dynamic> toJson() => $ProvinceResultToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}