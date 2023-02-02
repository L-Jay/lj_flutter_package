

import 'package:example/generated/json/base/json_convert_content.dart';
import 'package:example/home/model/province_model.dart';

ProvinceModel $ProvinceModelFromJson(Map<String, dynamic> json) {
	final ProvinceModel provinceModel = ProvinceModel();
	final String? reason = jsonConvert.convert<String>(json['reason']);
	if (reason != null) {
		provinceModel.reason = reason;
	}
	final List<ProvinceResult>? result = jsonConvert.convertListNotNull<ProvinceResult>(json['result']);
	if (result != null) {
		provinceModel.result = result;
	}
	final int? errorCode = jsonConvert.convert<int>(json['error_code']);
	if (errorCode != null) {
		provinceModel.errorCode = errorCode;
	}
	return provinceModel;
}

Map<String, dynamic> $ProvinceModelToJson(ProvinceModel entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['reason'] = entity.reason;
	data['result'] =  entity.result?.map((v) => v.toJson()).toList();
	data['error_code'] = entity.errorCode;
	return data;
}

ProvinceResult $ProvinceResultFromJson(Map<String, dynamic> json) {
	final ProvinceResult provinceResult = ProvinceResult();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		provinceResult.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		provinceResult.name = name;
	}
	final String? fid = jsonConvert.convert<String>(json['fid']);
	if (fid != null) {
		provinceResult.fid = fid;
	}
	final String? levelId = jsonConvert.convert<String>(json['level_id']);
	if (levelId != null) {
		provinceResult.levelId = levelId;
	}
	return provinceResult;
}

Map<String, dynamic> $ProvinceResultToJson(ProvinceResult entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['fid'] = entity.fid;
	data['level_id'] = entity.levelId;
	return data;
}