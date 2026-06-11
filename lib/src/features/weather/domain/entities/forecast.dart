class ForecastItem {
  final DateTime dateTime;
  final double temperature;
  final double feelsLike;
  final String description;
  final String iconCode;
  final double windSpeed;
  final int humidity;

  const ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.iconCode,
    required this.windSpeed,
    required this.humidity,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}

class Forecast {
  final List<ForecastItem> items;

  const Forecast({
    required this.items,
  });
}
