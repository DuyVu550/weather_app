import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_weather_usecase.dart';
import '../../domain/usecases/get_forecast_usecase.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/forecast.dart';
import 'location_provider.dart';
import 'saved_locations_provider.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers (dependency injection thuần Riverpod)
// ---------------------------------------------------------------------------

/// Cung cấp một http.Client dùng chung.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  // Tự động đóng client khi provider bị huỷ.
  ref.onDispose(client.close);
  return client;
});

/// Cung cấp [WeatherRemoteDataSource].
final weatherRemoteDataSourceProvider =
    Provider<WeatherRemoteDataSource>((ref) {
  return WeatherRemoteDataSource(client: ref.watch(httpClientProvider));
});

/// Cung cấp [WeatherRepository].
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(
    remoteDataSource: ref.watch(weatherRemoteDataSourceProvider),
  );
});

/// Cung cấp [GetWeatherUseCase].
final getWeatherUseCaseProvider = Provider<GetWeatherUseCase>((ref) {
  return GetWeatherUseCase(repository: ref.watch(weatherRepositoryProvider));
});

/// Cung cấp [GetForecastUseCase].
final getForecastUseCaseProvider = Provider<GetForecastUseCase>((ref) {
  return GetForecastUseCase(repository: ref.watch(weatherRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Weather provider — lắng nghe locationProvider và tự động fetch thời tiết.
// ---------------------------------------------------------------------------

final weatherProvider = FutureProvider<Weather>((ref) async {
  // Lấy trạng thái địa điểm đã chọn
  final savedState = ref.watch(savedLocationsProvider);
  
  Location location;
  if (savedState.selectedLocation != null) {
    // Dùng vị trí đã chọn
    location = Location(
      latitude: savedState.selectedLocation!.latitude,
      longitude: savedState.selectedLocation!.longitude,
    );
  } else {
    // Dùng GPS
    location = await ref.watch(locationProvider.future);
  }

  final useCase = ref.watch(getWeatherUseCaseProvider);
  return useCase(location);
});

final forecastProvider = FutureProvider<Forecast>((ref) async {
  // Lấy trạng thái địa điểm đã chọn tương tự như weatherProvider
  final savedState = ref.watch(savedLocationsProvider);
  
  Location location;
  if (savedState.selectedLocation != null) {
    location = Location(
      latitude: savedState.selectedLocation!.latitude,
      longitude: savedState.selectedLocation!.longitude,
    );
  } else {
    location = await ref.watch(locationProvider.future);
  }

  final useCase = ref.watch(getForecastUseCaseProvider);
  return useCase(location);
});
