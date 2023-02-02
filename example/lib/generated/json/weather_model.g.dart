

import 'package:example/generated/json/base/json_convert_content.dart';
import 'package:example/home/model/weather_model.dart';

WeatherModel $WeatherModelFromJson(Map<String, dynamic> json) {
	final WeatherModel weatherModel = WeatherModel();
	final String? reason = jsonConvert.convert<String>(json['reason']);
	if (reason != null) {
		weatherModel.reason = reason;
	}
	final WeatherResult? result = jsonConvert.convert<WeatherResult>(json['result']);
	if (result != null) {
		weatherModel.result = result;
	}
	final int? errorCode = jsonConvert.convert<int>(json['error_code']);
	if (errorCode != null) {
		weatherModel.errorCode = errorCode;
	}
	return weatherModel;
}

Map<String, dynamic> $WeatherModelToJson(WeatherModel entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['reason'] = entity.reason;
	data['result'] = entity.result?.toJson();
	data['error_code'] = entity.errorCode;
	return data;
}

WeatherResult $WeatherResultFromJson(Map<String, dynamic> json) {
	final WeatherResult weatherResult = WeatherResult();
	final String? city = jsonConvert.convert<String>(json['city']);
	if (city != null) {
		weatherResult.city = city;
	}
	final WeatherResultRealtime? realtime = jsonConvert.convert<WeatherResultRealtime>(json['realtime']);
	if (realtime != null) {
		weatherResult.realtime = realtime;
	}
	final List<WeatherResultFuture>? future = jsonConvert.convertListNotNull<WeatherResultFuture>(json['future']);
	if (future != null) {
		weatherResult.future = future;
	}
	return weatherResult;
}

Map<String, dynamic> $WeatherResultToJson(WeatherResult entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['city'] = entity.city;
	data['realtime'] = entity.realtime?.toJson();
	data['future'] =  entity.future?.map((v) => v.toJson()).toList();
	return data;
}

WeatherResultRealtime $WeatherResultRealtimeFromJson(Map<String, dynamic> json) {
	final WeatherResultRealtime weatherResultRealtime = WeatherResultRealtime();
	final String? temperature = jsonConvert.convert<String>(json['temperature']);
	if (temperature != null) {
		weatherResultRealtime.temperature = temperature;
	}
	final String? humidity = jsonConvert.convert<String>(json['humidity']);
	if (humidity != null) {
		weatherResultRealtime.humidity = humidity;
	}
	final String? info = jsonConvert.convert<String>(json['info']);
	if (info != null) {
		weatherResultRealtime.info = info;
	}
	final String? wid = jsonConvert.convert<String>(json['wid']);
	if (wid != null) {
		weatherResultRealtime.wid = wid;
	}
	final String? direct = jsonConvert.convert<String>(json['direct']);
	if (direct != null) {
		weatherResultRealtime.direct = direct;
	}
	final String? power = jsonConvert.convert<String>(json['power']);
	if (power != null) {
		weatherResultRealtime.power = power;
	}
	final String? aqi = jsonConvert.convert<String>(json['aqi']);
	if (aqi != null) {
		weatherResultRealtime.aqi = aqi;
	}
	return weatherResultRealtime;
}

Map<String, dynamic> $WeatherResultRealtimeToJson(WeatherResultRealtime entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['temperature'] = entity.temperature;
	data['humidity'] = entity.humidity;
	data['info'] = entity.info;
	data['wid'] = entity.wid;
	data['direct'] = entity.direct;
	data['power'] = entity.power;
	data['aqi'] = entity.aqi;
	return data;
}

WeatherResultFuture $WeatherResultFutureFromJson(Map<String, dynamic> json) {
	final WeatherResultFuture weatherResultFuture = WeatherResultFuture();
	final String? date = jsonConvert.convert<String>(json['date']);
	if (date != null) {
		weatherResultFuture.date = date;
	}
	final String? temperature = jsonConvert.convert<String>(json['temperature']);
	if (temperature != null) {
		weatherResultFuture.temperature = temperature;
	}
	final String? weather = jsonConvert.convert<String>(json['weather']);
	if (weather != null) {
		weatherResultFuture.weather = weather;
	}
	final WeatherResultFutureWid? wid = jsonConvert.convert<WeatherResultFutureWid>(json['wid']);
	if (wid != null) {
		weatherResultFuture.wid = wid;
	}
	final String? direct = jsonConvert.convert<String>(json['direct']);
	if (direct != null) {
		weatherResultFuture.direct = direct;
	}
	return weatherResultFuture;
}

Map<String, dynamic> $WeatherResultFutureToJson(WeatherResultFuture entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['date'] = entity.date;
	data['temperature'] = entity.temperature;
	data['weather'] = entity.weather;
	data['wid'] = entity.wid?.toJson();
	data['direct'] = entity.direct;
	return data;
}

WeatherResultFutureWid $WeatherResultFutureWidFromJson(Map<String, dynamic> json) {
	final WeatherResultFutureWid weatherResultFutureWid = WeatherResultFutureWid();
	final String? day = jsonConvert.convert<String>(json['day']);
	if (day != null) {
		weatherResultFutureWid.day = day;
	}
	final String? night = jsonConvert.convert<String>(json['night']);
	if (night != null) {
		weatherResultFutureWid.night = night;
	}
	return weatherResultFutureWid;
}

Map<String, dynamic> $WeatherResultFutureWidToJson(WeatherResultFutureWid entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['day'] = entity.day;
	data['night'] = entity.night;
	return data;
}