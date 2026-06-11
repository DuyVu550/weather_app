import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app/src/features/weather/domain/entities/location.dart';
import 'package:weather_app/src/features/weather/domain/entities/weather.dart';
import 'package:weather_app/src/features/weather/domain/repositories/weather_repository.dart';
import 'package:weather_app/src/features/weather/domain/usecases/get_weather_usecase.dart';

import 'get_weather_usecase_test.mocks.dart';

@GenerateNiceMocks([MockSpec<WeatherRepository>()])
void main() {
  late GetWeatherUseCase usecase;
  late MockWeatherRepository mockWeatherRepository;

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
    usecase = GetWeatherUseCase(repository: mockWeatherRepository);
  });

  const tLocation = Location(latitude: 21.0285, longitude: 105.8542);
  const tWeather = Weather(
    cityName: 'Hanoi',
    country: 'VN',
    temperature: 25.0,
    feelsLike: 26.0,
    humidity: 80,
    windSpeed: 3.5,
    description: 'clear sky',
    iconCode: '01d',
  );

  test('nên nhận dữ liệu Weather từ repository', () async {
    // Chuẩn bị
    when(mockWeatherRepository.getWeather(any))
        .thenAnswer((_) async => tWeather);

    // Thực thi
    final result = await usecase(tLocation);

    // Kiểm tra
    expect(result, tWeather);
    verify(mockWeatherRepository.getWeather(tLocation));
    verifyNoMoreInteractions(mockWeatherRepository);
  });
}
