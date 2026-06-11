/// Entity thời tiết thuần túy, không phụ thuộc vào bất kỳ package nào.
class Weather {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;      // %
  final double windSpeed;  // m/s
  final String description;
  final String iconCode;   // ví dụ: "10d"

  const Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.iconCode,
  });

  /// URL ảnh icon thời tiết từ OpenWeatherMap.
  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}
