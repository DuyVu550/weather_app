import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/src/features/weather/data/models/forecast_model.dart';
import 'package:weather_app/src/features/weather/domain/entities/forecast.dart';

void main() {
  final tDateTime = DateTime.fromMillisecondsSinceEpoch(1661871600 * 1000, isUtc: true);
  final tForecastItemModel = ForecastItemModel(
    dateTime: tDateTime,
    temperature: 296.76,
    feelsLike: 296.98,
    description: 'light rain',
    iconCode: '10d',
    windSpeed: 0.62,
    humidity: 69,
  );

  final tForecastModel = ForecastModel(items: [tForecastItemModel]);

  test('ForecastModel should be a subclass of Forecast entity', () {
    expect(tForecastModel, isA<Forecast>());
  });

  test('ForecastItemModel should be a subclass of ForecastItem entity', () {
    expect(tForecastItemModel, isA<ForecastItem>());
  });

  group('fromJson', () {
    test('should return a valid ForecastModel from JSON', () {
      // arrange
      final Map<String, dynamic> jsonMap = json.decode('''
      {
        "cod": "200",
        "message": 0,
        "cnt": 1,
        "list": [
          {
            "dt": 1661871600,
            "main": {
              "temp": 296.76,
              "feels_like": 296.98,
              "humidity": 69
            },
            "weather": [
              {
                "description": "light rain",
                "icon": "10d"
              }
            ],
            "wind": {
              "speed": 0.62
            }
          }
        ]
      }
      ''');

      // act
      final result = ForecastModel.fromJson(jsonMap);

      // assert
      expect(result.items.length, 1);
      final item = result.items.first;
      expect(item.dateTime, tForecastItemModel.dateTime);
      expect(item.temperature, tForecastItemModel.temperature);
      expect(item.feelsLike, tForecastItemModel.feelsLike);
      expect(item.description, tForecastItemModel.description);
      expect(item.iconCode, tForecastItemModel.iconCode);
      expect(item.windSpeed, tForecastItemModel.windSpeed);
      expect(item.humidity, tForecastItemModel.humidity);
    });
  });
}
