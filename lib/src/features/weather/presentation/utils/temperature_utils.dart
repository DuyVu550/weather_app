import '../providers/settings_provider.dart';

class TemperatureUtils {
  static double convertTemp(double tempC, TemperatureUnit unit) {
    if (unit == TemperatureUnit.fahrenheit) {
      return (tempC * 9 / 5) + 32;
    }
    return tempC;
  }

  static String formatTemp(double tempC, TemperatureUnit unit) {
    final temp = convertTemp(tempC, unit);
    final symbol = unit == TemperatureUnit.fahrenheit ? '°F' : '°C';
    return '${temp.round()}$symbol';
  }
}
