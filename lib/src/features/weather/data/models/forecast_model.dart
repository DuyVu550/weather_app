import '../../domain/entities/forecast.dart';

class ForecastModel extends Forecast {
  const ForecastModel({required super.items});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List<dynamic>? ?? [];
    return ForecastModel(
      items: list.map((item) => ForecastItemModel.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class ForecastItemModel extends ForecastItem {
  const ForecastItemModel({
    required super.dateTime,
    required super.temperature,
    required super.feelsLike,
    required super.description,
    required super.iconCode,
    required super.windSpeed,
    required super.humidity,
  });

  factory ForecastItemModel.fromJson(Map<String, dynamic> json) {
    return ForecastItemModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000, isUtc: true),
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      iconCode: json['weather'][0]['icon'] as String,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
    );
  }
}
