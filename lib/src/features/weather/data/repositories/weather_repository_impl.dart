import '../../domain/entities/location.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

/// Triển khai cụ thể của [WeatherRepository] sử dụng remote data source.
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Weather> getWeather(Location location) {
    return remoteDataSource.fetchWeather(
      location.latitude,
      location.longitude,
    );
  }

  @override
  Future<Forecast> getForecast(Location location) {
    return remoteDataSource.fetchForecast(
      location.latitude,
      location.longitude,
    );
  }
}
