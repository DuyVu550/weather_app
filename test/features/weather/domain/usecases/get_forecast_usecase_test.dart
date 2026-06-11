import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app/src/features/weather/domain/entities/forecast.dart';
import 'package:weather_app/src/features/weather/domain/entities/location.dart';
import 'package:weather_app/src/features/weather/domain/repositories/weather_repository.dart';
import 'package:weather_app/src/features/weather/domain/usecases/get_forecast_usecase.dart';

import 'get_forecast_usecase_test.mocks.dart';

@GenerateNiceMocks([MockSpec<WeatherRepository>()])
void main() {
  late GetForecastUseCase usecase;
  late MockWeatherRepository mockWeatherRepository;

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
    usecase = GetForecastUseCase(repository: mockWeatherRepository);
  });

  const tLocation = Location(latitude: 21.0285, longitude: 105.8542);
  final tForecast = Forecast(items: [
    ForecastItem(
      dateTime: DateTime.now(),
      temperature: 25.0,
      feelsLike: 26.0,
      description: 'clear sky',
      iconCode: '01d',
      windSpeed: 3.5,
      humidity: 80,
    )
  ]);

  test('nên nhận dữ liệu Forecast từ repository', () async {
    // Chuẩn bị
    when(mockWeatherRepository.getForecast(any))
        .thenAnswer((_) async => tForecast);

    // Thực thi
    final result = await usecase(tLocation);

    // Kiểm tra
    expect(result, tForecast);
    verify(mockWeatherRepository.getForecast(tLocation));
    verifyNoMoreInteractions(mockWeatherRepository);
  });
}
