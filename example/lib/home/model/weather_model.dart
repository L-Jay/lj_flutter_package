
import 'dart:convert';

import 'package:example/generated/json/base/json_field.dart';
import 'package:example/generated/json/weather_model.g.dart';

@JsonSerializable()
class WeatherModel {

	String? reason;
	WeatherResult? result;
	@JSONField(name: "error_code")
	int? errorCode;
  
  WeatherModel();

  factory WeatherModel.fromJson(Map<String, dynamic> json) => $WeatherModelFromJson(json);

  Map<String, dynamic> toJson() => $WeatherModelToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class WeatherResult {

	String? city;
	WeatherResultRealtime? realtime;
	List<WeatherResultFuture>? future;
  
  WeatherResult();

  factory WeatherResult.fromJson(Map<String, dynamic> json) => $WeatherResultFromJson(json);

  Map<String, dynamic> toJson() => $WeatherResultToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class WeatherResultRealtime {

	String? temperature;
	String? humidity;
	String? info;
	String? wid;
	String? direct;
	String? power;
	String? aqi;
  
  WeatherResultRealtime();

  factory WeatherResultRealtime.fromJson(Map<String, dynamic> json) => $WeatherResultRealtimeFromJson(json);

  Map<String, dynamic> toJson() => $WeatherResultRealtimeToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class WeatherResultFuture {

	String? date;
	String? temperature;
	String? weather;
	WeatherResultFutureWid? wid;
	String? direct;
  
  WeatherResultFuture();

  factory WeatherResultFuture.fromJson(Map<String, dynamic> json) => $WeatherResultFutureFromJson(json);

  Map<String, dynamic> toJson() => $WeatherResultFutureToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class WeatherResultFutureWid {

	String? day;
	String? night;
  
  WeatherResultFutureWid();

  factory WeatherResultFutureWid.fromJson(Map<String, dynamic> json) => $WeatherResultFutureWidFromJson(json);

  Map<String, dynamic> toJson() => $WeatherResultFutureWidToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}