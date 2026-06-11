import '../../domain/entities/weather.dart';

/// Model ánh xạ JSON từ OpenWeatherMap API sang entity [Weather].
class WeatherModel extends Weather {
  const WeatherModel({
    required super.cityName,
    required super.country,
    required super.temperature,
    required super.feelsLike,
    required super.humidity,
    required super.windSpeed,
    required super.description,
    required super.iconCode,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final weatherList = json['weather'] as List<dynamic>;
    final weatherInfo = weatherList.first as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>;

    return WeatherModel(
      cityName: json['name'] as String,
      country: sys['country'] as String,
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      humidity: (main['humidity'] as num).toInt(),
      windSpeed: (wind['speed'] as num).toDouble(),
      description: weatherInfo['description'] as String,
      iconCode: weatherInfo['icon'] as String,
    );
  }
}
