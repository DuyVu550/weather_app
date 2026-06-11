import '../../domain/entities/location.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';

/// Use case lấy thời tiết theo tọa độ vị trí.
class GetWeatherUseCase {
  final WeatherRepository repository;

  const GetWeatherUseCase({required this.repository});

  Future<Weather> call(Location location) => repository.getWeather(location);
}
