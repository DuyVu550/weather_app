import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/src/core/error/failures.dart';
import 'package:weather_app/src/features/weather/presentation/providers/location_provider.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

// ==========================================================================
// Mock class thay thế Geolocator thật để kiểm thử
// ==========================================================================
class MockGeolocatorPlatform extends GeolocatorPlatform
    with MockPlatformInterfaceMixin {
  bool isLocationServiceEnabledResult = true;
  LocationPermission checkPermissionResult = LocationPermission.always;
  LocationPermission requestPermissionResult = LocationPermission.always;
  bool shouldThrowOnGetPosition = false;

  Position currentPositionResult = Position(
    longitude: 105.8542,
    latitude: 21.0285,
    timestamp: DateTime(2026, 6, 10),
    accuracy: 1.0,
    altitude: 1.0,
    heading: 1.0,
    speed: 1.0,
    speedAccuracy: 1.0,
    altitudeAccuracy: 1.0,
    headingAccuracy: 1.0,
  );

  @override
  Future<bool> isLocationServiceEnabled() async =>
      isLocationServiceEnabledResult;

  @override
  Future<LocationPermission> checkPermission() async =>
      checkPermissionResult;

  @override
  Future<LocationPermission> requestPermission() async =>
      requestPermissionResult;

  @override
  Future<Position> getCurrentPosition(
      {LocationSettings? locationSettings}) async {
    if (shouldThrowOnGetPosition) {
      throw Exception('Không thể lấy vị trí');
    }
    return currentPositionResult;
  }

  @override
  Future<Position?> getLastKnownPosition({bool forceLocationManager = false}) async {
    if (shouldThrowOnGetPosition) return null;
    return currentPositionResult;
  }
}

void main() {
  late MockGeolocatorPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockPlatform;
  });

  // =========================================================================
  // NHÓM 1: Thành công — GPS bật, quyền đã được cấp
  // =========================================================================
  group('Lấy vị trí thành công', () {
    test(
      'trả về Location đúng tọa độ khi GPS bật và quyền đã được cấp',
      () async {
        // Chuẩn bị — mặc định mock đã cho quyền
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Thực thi
        final location = await container.read(locationProvider.future);

        // Kiểm tra
        expect(location.latitude, 21.0285);
        expect(location.longitude, 105.8542);
      },
    );
  });

  // =========================================================================
  // NHÓM 2: Dịch vụ GPS bị tắt
  // =========================================================================
  group('Dịch vụ vị trí bị tắt', () {
    test(
      'ném ra LocationFailure khi GPS bị tắt trên thiết bị',
      () async {
        // Chuẩn bị
        mockPlatform.isLocationServiceEnabledResult = false;
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Thực thi & Kiểm tra
        await expectLater(
          container.read(locationProvider.future),
          throwsA(
            isA<LocationFailure>().having(
              (e) => e.message,
              'thông báo lỗi',
              'Dịch vụ vị trí đang bị tắt. Vui lòng bật GPS.',
            ),
          ),
        );
      },
    );
  });

  // =========================================================================
  // NHÓM 3: Quyền truy cập vị trí
  // =========================================================================
  group('Quyền truy cập vị trí bị từ chối', () {
    test(
      'ném ra LocationFailure khi người dùng từ chối quyền lần đầu VÀ cả lần xin lại',
      () async {
        // Chuẩn bị — checkPermission = denied, requestPermission cũng = denied
        mockPlatform.checkPermissionResult = LocationPermission.denied;
        mockPlatform.requestPermissionResult = LocationPermission.denied;
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Thực thi & Kiểm tra
        await expectLater(
          container.read(locationProvider.future),
          throwsA(
            isA<LocationFailure>().having(
              (e) => e.message,
              'thông báo lỗi',
              'Quyền truy cập vị trí đã bị từ chối.',
            ),
          ),
        );
      },
    );

    test(
      'lấy được vị trí khi người dùng từ chối lần đầu nhưng chấp nhận lần xin lại',
      () async {
        // Chuẩn bị — checkPermission = denied, requestPermission = always
        mockPlatform.checkPermissionResult = LocationPermission.denied;
        mockPlatform.requestPermissionResult = LocationPermission.always;
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Thực thi
        final location = await container.read(locationProvider.future);

        // Kiểm tra — phải lấy được vị trí bình thường
        expect(location.latitude, 21.0285);
        expect(location.longitude, 105.8542);
      },
    );

    test(
      'ném ra LocationFailure khi người dùng chọn "Không bao giờ hỏi lại" (deniedForever)',
      () async {
        // Chuẩn bị
        mockPlatform.checkPermissionResult = LocationPermission.deniedForever;
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Thực thi & Kiểm tra
        await expectLater(
          container.read(locationProvider.future),
          throwsA(
            isA<LocationFailure>().having(
              (e) => e.message,
              'thông báo lỗi',
              contains('vĩnh viễn'),
            ),
          ),
        );
      },
    );
  });

  // =========================================================================
  // NHÓM 4: Lỗi khi lấy vị trí (GPS có quyền nhưng không lấy được tọa độ)
  // =========================================================================
  group('Lỗi khi lấy tọa độ GPS', () {
    test(
      'ném ra lỗi khi thiết bị có quyền nhưng getCurrentPosition thất bại',
      () async {
        // Chuẩn bị — GPS bật, quyền có, nhưng getCurrentPosition ném lỗi
        mockPlatform.shouldThrowOnGetPosition = true;
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Thực thi & Kiểm tra — bất kỳ exception nào đều không được crash app
        await expectLater(
          container.read(locationProvider.future),
          throwsA(isA<LocationFailure>()),
        );
      },
    );
  });

  // =========================================================================
  // NHÓM 5: Kiểm tra Failure.toString() hiển thị đúng tiếng Việt
  // =========================================================================
  group('Failure.toString() hiển thị đúng', () {
    test(
      'LocationFailure.toString() trả về message tiếng Việt chứ không phải "Instance of..."',
      () {
        const failure = LocationFailure('Quyền truy cập vị trí đã bị từ chối.');
        // Kiểm tra — toString() phải trả về nội dung message, không phải tên class
        expect(failure.toString(), 'Quyền truy cập vị trí đã bị từ chối.');
        expect(failure.toString(), isNot(contains('Instance of')));
      },
    );

    test(
      'NetworkFailure.toString() trả về đúng message mặc định',
      () {
        const failure = NetworkFailure();
        expect(failure.toString(), 'Không có kết nối Internet.');
      },
    );

    test(
      'ServerFailure.toString() trả về đúng message tùy chỉnh',
      () {
        const failure = ServerFailure('API Key không hợp lệ hoặc đã hết hạn.');
        expect(failure.toString(), 'API Key không hợp lệ hoặc đã hết hạn.');
      },
    );
  });
}
