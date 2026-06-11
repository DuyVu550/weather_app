import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/src/features/weather/data/models/weather_model.dart';
import 'package:weather_app/src/features/weather/domain/entities/weather.dart';

void main() {
  const tWeatherModel = WeatherModel(
    cityName: 'Hanoi',
    country: 'VN',
    temperature: 25.0,
    feelsLike: 26.0,
    humidity: 80,
    windSpeed: 3.5,
    description: 'clear sky',
    iconCode: '01d',
  );

  test('nên kế thừa từ class Weather entity', () {
    expect(tWeatherModel, isA<Weather>());
  });

  group('fromJson', () {
    test('nên trả về một WeatherModel hợp lệ từ JSON chuẩn', () {
      // Chuẩn bị
      final Map<String, dynamic> jsonMap = json.decode('''
      {
        "weather": [
          {
            "description": "clear sky",
            "icon": "01d"
          }
        ],
        "main": {
          "temp": 25.0,
          "feels_like": 26.0,
          "humidity": 80
        },
        "wind": {
          "speed": 3.5
        },
        "sys": {
          "country": "VN"
        },
        "name": "Hanoi"
      }
      ''');

      // Thực thi
      final result = WeatherModel.fromJson(jsonMap);

      // Kiểm tra
      expect(result.cityName, tWeatherModel.cityName);
      expect(result.country, tWeatherModel.country);
      expect(result.temperature, tWeatherModel.temperature);
      expect(result.feelsLike, tWeatherModel.feelsLike);
      expect(result.humidity, tWeatherModel.humidity);
      expect(result.windSpeed, tWeatherModel.windSpeed);
      expect(result.description, tWeatherModel.description);
      expect(result.iconCode, tWeatherModel.iconCode);
    });

    test('nên xử lý thành công khi nhiệt độ là số nguyên (int) trả về từ JSON', () {
      // Chuẩn bị
      final Map<String, dynamic> jsonMap = json.decode('''
      {
        "weather": [
          {
            "description": "clear sky",
            "icon": "01d"
          }
        ],
        "main": {
          "temp": 25,
          "feels_like": 26,
          "humidity": 80
        },
        "wind": {
          "speed": 3
        },
        "sys": {
          "country": "VN"
        },
        "name": "Hanoi"
      }
      ''');

      // Thực thi
      final result = WeatherModel.fromJson(jsonMap);

      // Kiểm tra ép kiểu toDouble() thành công
      expect(result.temperature, 25.0);
      expect(result.feelsLike, 26.0);
      expect(result.windSpeed, 3.0);
    });
  });
}
