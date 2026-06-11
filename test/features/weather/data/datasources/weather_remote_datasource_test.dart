import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app/src/core/error/failures.dart';
import 'package:weather_app/src/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:weather_app/src/features/weather/data/models/weather_model.dart';
import 'package:weather_app/src/features/weather/data/models/forecast_model.dart';


import 'weather_remote_datasource_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  late WeatherRemoteDataSource dataSource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = WeatherRemoteDataSource(client: mockHttpClient);
  });

  const tLatitude = 21.0285;
  const tLongitude = 105.8542;

  final tJsonHopLe = json.encode({
    'weather': [
      {'description': 'clear sky', 'icon': '01d'},
    ],
    'main': {'temp': 25.0, 'feels_like': 26.0, 'humidity': 80},
    'wind': {'speed': 3.5},
    'sys': {'country': 'VN'},
    'name': 'Hanoi',
  });

  // =========================================================================
  // NHÓM 1: Gọi API thành công
  // =========================================================================
  group('Gọi API thành công (status 200)', () {
    test(
      'trả về WeatherModel đúng khi server trả về 200 với JSON hợp lệ',
      () async {
        // Chuẩn bị
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(tJsonHopLe, 200));

        // Thực thi
        final ketQua = await dataSource.fetchWeather(tLatitude, tLongitude);

        // Kiểm tra — verify TẤT CẢ các thuộc tính
        expect(ketQua, isA<WeatherModel>());
        expect(ketQua.cityName, 'Hanoi');
        expect(ketQua.country, 'VN');
        expect(ketQua.temperature, 25.0);
        expect(ketQua.feelsLike, 26.0);
        expect(ketQua.humidity, 80);
        expect(ketQua.windSpeed, 3.5);
        expect(ketQua.description, 'clear sky');
        expect(ketQua.iconCode, '01d');
      },
    );

    test(
      'gửi đúng URL với tham số lat, lon, appid, units',
      () async {
        // Chuẩn bị
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(tJsonHopLe, 200));

        // Thực thi
        await dataSource.fetchWeather(tLatitude, tLongitude);

        // Kiểm tra — đảm bảo URL được gọi đúng
        final captured =
            verify(mockHttpClient.get(captureAny))
                .captured;
        final uri = captured.first as Uri;
        expect(uri.host, 'api.openweathermap.org');
        expect(uri.path, '/data/2.5/weather');
        expect(uri.queryParameters['lat'], tLatitude.toString());
        expect(uri.queryParameters['lon'], tLongitude.toString());
        expect(uri.queryParameters['units'], 'metric');
        expect(uri.queryParameters['appid'], isNotEmpty);
      },
    );
  });

  // =========================================================================
  // NHÓM 2: Mất kết nối mạng
  // =========================================================================
  group('Mất kết nối Internet', () {
    test(
      'ném ra NetworkFailure khi gặp SocketException (mất mạng hoàn toàn)',
      () async {
        // Chuẩn bị
        when(mockHttpClient.get(any))
            .thenThrow(const SocketException('Không tìm thấy host'));

        // Kiểm tra
        expect(
          () => dataSource.fetchWeather(tLatitude, tLongitude),
          throwsA(
            isA<NetworkFailure>().having(
              (f) => f.message,
              'thông báo lỗi',
              'Không có kết nối Internet.',
            ),
          ),
        );
      },
    );

    test(
      'ném ra NetworkFailure khi gặp HttpException (kết nối bị ngắt giữa chừng)',
      () async {
        // Chuẩn bị
        when(mockHttpClient.get(any))
            .thenThrow(const HttpException('Kết nối bị đóng'));

        // Kiểm tra
        expect(
          () => dataSource.fetchWeather(tLatitude, tLongitude),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );

    test(
      'ném ra NetworkFailure khi gặp bất kỳ Exception nào trong quá trình gọi API',
      () async {
        // Chuẩn bị — ví dụ: timeout hoặc lỗi TLS
        when(mockHttpClient.get(any))
            .thenThrow(Exception('Hết thời gian chờ'));

        // Kiểm tra
        expect(
          () => dataSource.fetchWeather(tLatitude, tLongitude),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );
  });

  // =========================================================================
  // NHÓM 3: Lỗi API Key (401)
  // =========================================================================
  group('Lỗi API Key (status 401)', () {
    test(
      'ném ra ServerFailure với thông báo "API Key không hợp lệ" khi status 401',
      () async {
        // Chuẩn bị
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response('Unauthorized', 401));

        // Kiểm tra
        expect(
          () => dataSource.fetchWeather(tLatitude, tLongitude),
          throwsA(
            isA<ServerFailure>().having(
              (f) => f.message,
              'thông báo lỗi',
              'API Key không hợp lệ hoặc đã hết hạn.',
            ),
          ),
        );
      },
    );
  });

  // =========================================================================
  // NHÓM 4: Vượt quá giới hạn gọi API (429)
  // =========================================================================
  group('Vượt quá giới hạn gọi API (status 429)', () {
    test(
      'ném ra ServerFailure với thông báo "vượt quá giới hạn" khi status 429',
      () async {
        // Chuẩn bị
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response('Too Many Requests', 429));

        // Kiểm tra
        expect(
          () => dataSource.fetchWeather(tLatitude, tLongitude),
          throwsA(
            isA<ServerFailure>().having(
              (f) => f.message,
              'thông báo lỗi',
              'Đã vượt quá giới hạn gọi API. Vui lòng thử lại sau.',
            ),
          ),
        );
      },
    );
  });

  // =========================================================================
  // NHÓM 5: Lỗi server khác (5xx, v.v.)
  // =========================================================================
  group('Lỗi server khác', () {
    test(
      'ném ra ServerFailure kèm status code khi server trả về 500',
      () async {
        // Chuẩn bị
        when(mockHttpClient.get(any)).thenAnswer(
            (_) async => http.Response('Internal Server Error', 500));

        // Kiểm tra
        expect(
          () => dataSource.fetchWeather(tLatitude, tLongitude),
          throwsA(
            isA<ServerFailure>().having(
              (f) => f.message,
              'thông báo lỗi',
              'Lỗi máy chủ (500)',
            ),
          ),
        );
      },
    );

    test(
      'ném ra ServerFailure kèm status code khi server trả về 503 (bảo trì)',
      () async {
        // Chuẩn bị
        when(mockHttpClient.get(any)).thenAnswer(
            (_) async => http.Response('Service Unavailable', 503));

        // Kiểm tra
        expect(
          () => dataSource.fetchWeather(tLatitude, tLongitude),
          throwsA(
            isA<ServerFailure>().having(
              (f) => f.message,
              'thông báo lỗi',
              'Lỗi máy chủ (503)',
            ),
          ),
        );
      },
    );
  });

  // =========================================================================
  // NHÓM 6: JSON bị lỗi / hỏng
  // =========================================================================
  group('JSON trả về bị lỗi hoặc không hợp lệ', () {
    test(
      'ném ra lỗi khi server trả về 200 nhưng body rỗng (JSON hỏng)',
      () async {
        // Chuẩn bị — body rỗng, json.decode sẽ ném FormatException
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response('', 200));

        // Kiểm tra — app không được crash, phải ném ra exception
        expect(
          () => dataSource.fetchWeather(tLatitude, tLongitude),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'ném ra lỗi khi server trả về 200 nhưng JSON thiếu key "weather"',
      () async {
        // Chuẩn bị — JSON thiếu key "weather"
        final jsonThieuKey = json.encode({
          'main': {'temp': 25},
          'name': 'Hanoi',
        });
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(jsonThieuKey, 200));

        // Kiểm tra — ném lỗi TypeError vì cast null thành List
        expect(
          () => dataSource.fetchWeather(tLatitude, tLongitude),
          throwsA(isA<TypeError>()),
        );
      },
    );
  });

  // =========================================================================
  // NHÓM 7: Gọi API fetchForecast thành công
  // =========================================================================
  group('fetchForecast', () {
    final tForecastJson = json.encode({
      "cod": "200",
      "message": 0,
      "cnt": 1,
      "list": [
        {
          "dt": 1661871600,
          "main": {"temp": 296.76, "feels_like": 296.98, "humidity": 69},
          "weather": [{"description": "light rain", "icon": "10d"}],
          "wind": {"speed": 0.62}
        }
      ]
    });

    test('trả về ForecastModel khi gọi API thành công (200)', () async {
      when(mockHttpClient.get(any))
          .thenAnswer((_) async => http.Response(tForecastJson, 200));

      final result = await dataSource.fetchForecast(tLatitude, tLongitude);

      expect(result, isA<ForecastModel>());
      expect(result.items.length, 1);
    });

    test('gửi đúng URL cho forecast', () async {
      when(mockHttpClient.get(any))
          .thenAnswer((_) async => http.Response(tForecastJson, 200));

      await dataSource.fetchForecast(tLatitude, tLongitude);

      final captured = verify(mockHttpClient.get(captureAny)).captured;
      final uri = captured.first as Uri;
      expect(uri.path, '/data/2.5/forecast');
      expect(uri.queryParameters['lat'], tLatitude.toString());
      expect(uri.queryParameters['lon'], tLongitude.toString());
    });
  });
}
