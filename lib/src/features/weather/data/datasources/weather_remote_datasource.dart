import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherRemoteDataSource {
  final http.Client client;

  WeatherRemoteDataSource({required this.client});

  /// Fetches weather data from OpenWeatherMap for the given coordinates.
  /// Throws [ServerFailure] when the response status is not 200.
  Future<WeatherModel> fetchWeather(double latitude, double longitude) async {
    final uri = Uri.https(
      Constants.openWeatherMapBaseUrl,
      '/data/2.5/weather',
      {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'appid': Constants.openWeatherMapApiKey,
        'units': 'metric',
      },
    );

    http.Response response;
    try {
      response = await client.get(uri);
    } catch (e, stack) {
      print('DEBUG ERROR in fetchWeather: ${e.toString()}\\n${stack.toString()}');
      throw const NetworkFailure('Không có kết nối Internet.');
    }

    if (response.statusCode == 401) {
      throw const ServerFailure('API Key không hợp lệ hoặc đã hết hạn.');
    } else if (response.statusCode == 429) {
      throw const ServerFailure('Đã vượt quá giới hạn gọi API. Vui lòng thử lại sau.');
    } else if (response.statusCode != 200) {
      throw ServerFailure('Lỗi máy chủ (${response.statusCode})');
    }

    final jsonMap = json.decode(response.body) as Map<String, dynamic>;
    return WeatherModel.fromJson(jsonMap);
  }

  /// Fetches 5-day / 3-hour forecast data from OpenWeatherMap.
  Future<ForecastModel> fetchForecast(double latitude, double longitude) async {
    final uri = Uri.https(
      Constants.openWeatherMapBaseUrl,
      '/data/2.5/forecast',
      {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'appid': Constants.openWeatherMapApiKey,
        'units': 'metric',
      },
    );

    http.Response response;
    try {
      response = await client.get(uri);
    } catch (e) {
      throw const NetworkFailure('Không có kết nối Internet.');
    }

    if (response.statusCode == 401) {
      throw const ServerFailure('API Key không hợp lệ hoặc đã hết hạn.');
    } else if (response.statusCode == 429) {
      throw const ServerFailure('Đã vượt quá giới hạn gọi API. Vui lòng thử lại sau.');
    } else if (response.statusCode != 200) {
      throw ServerFailure('Lỗi máy chủ (${response.statusCode})');
    }

    final jsonMap = json.decode(response.body) as Map<String, dynamic>;
    return ForecastModel.fromJson(jsonMap);
  }
}
