import '../entities/forecast.dart';
import '../entities/location.dart';
import '../repositories/weather_repository.dart';

class GetForecastUseCase {
  final WeatherRepository repository;

  GetForecastUseCase({required this.repository});

  Future<Forecast> call(Location location) {
    return repository.getForecast(location);
  }
}
