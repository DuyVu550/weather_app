import '../../domain/entities/location.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/forecast.dart';

/// Contract (abstract interface) cho tầng repository thời tiết.
abstract class WeatherRepository {
  Future<Weather> getWeather(Location location);
  Future<Forecast> getForecast(Location location);
}
