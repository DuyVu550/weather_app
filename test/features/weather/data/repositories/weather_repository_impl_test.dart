import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app/src/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:weather_app/src/features/weather/data/models/weather_model.dart';
import 'package:weather_app/src/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/src/features/weather/domain/entities/location.dart';

import 'package:weather_app/src/features/weather/data/models/forecast_model.dart';

import 'weather_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<WeatherRemoteDataSource>()])
void main() {
  late WeatherRepositoryImpl repository;
  late MockWeatherRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockWeatherRemoteDataSource();
    repository = WeatherRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const tLocation = Location(latitude: 21.0285, longitude: 105.8542);
  const tWeatherModel = WeatherModel(
    cityName: 'Hanoi',
    country: 'VN',
    temperature: 25.0,
    feelsLike: 26.0,
    humidity: 80,
    windSpeed: 3.5,
    description: 'clear sky',
    iconCode: '01d',
  );

  group('getWeather', () {
    test('nên gọi fetchWeather từ remote data source với tọa độ chính xác', () async {
      // Chuẩn bị
      when(mockRemoteDataSource.fetchWeather(any, any))
          .thenAnswer((_) async => tWeatherModel);

      // Thực thi
      final result = await repository.getWeather(tLocation);

      // Kiểm tra
      verify(mockRemoteDataSource.fetchWeather(tLocation.latitude, tLocation.longitude));
      expect(result, equals(tWeatherModel));
    });

    test('nên ném lỗi ra ngoài khi remote data source gặp lỗi', () async {
      // Chuẩn bị
      when(mockRemoteDataSource.fetchWeather(any, any))
          .thenThrow(Exception('Lỗi mạng'));

      // Thực thi & Kiểm tra
      expect(() => repository.getWeather(tLocation), throwsException);
    });
  });

  final tForecastModel = ForecastModel(items: [
    ForecastItemModel(
      dateTime: DateTime.now(),
      temperature: 25.0,
      feelsLike: 26.0,
      description: 'clear sky',
      iconCode: '01d',
      windSpeed: 3.5,
      humidity: 80,
    )
  ]);

  group('getForecast', () {
    test('nên gọi fetchForecast từ remote data source với tọa độ chính xác', () async {
      when(mockRemoteDataSource.fetchForecast(any, any))
          .thenAnswer((_) async => tForecastModel);

      final result = await repository.getForecast(tLocation);

      verify(mockRemoteDataSource.fetchForecast(tLocation.latitude, tLocation.longitude));
      expect(result, equals(tForecastModel));
    });

    test('nên ném lỗi ra ngoài khi remote data source gặp lỗi', () async {
      when(mockRemoteDataSource.fetchForecast(any, any))
          .thenThrow(Exception('Lỗi mạng'));

      expect(() => repository.getForecast(tLocation), throwsException);
    });
  });
}
