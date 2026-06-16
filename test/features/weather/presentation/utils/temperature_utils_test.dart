import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/src/features/weather/presentation/providers/settings_provider.dart';
import 'package:weather_app/src/features/weather/presentation/utils/temperature_utils.dart';

void main() {
  group('TemperatureUtils', () {
    test('convertTemp converts correctly', () {
      expect(TemperatureUtils.convertTemp(0, TemperatureUnit.celsius), 0);
      expect(TemperatureUtils.convertTemp(0, TemperatureUnit.fahrenheit), 32);
      expect(TemperatureUtils.convertTemp(100, TemperatureUnit.fahrenheit), 212);
    });

    test('formatTemp formats correctly', () {
      expect(TemperatureUtils.formatTemp(0, TemperatureUnit.celsius), '0°C');
      expect(TemperatureUtils.formatTemp(0, TemperatureUnit.fahrenheit), '32°F');
      expect(TemperatureUtils.formatTemp(100.4, TemperatureUnit.celsius), '100°C');
      expect(TemperatureUtils.formatTemp(100.5, TemperatureUnit.celsius), '101°C');
    });
  });
}
