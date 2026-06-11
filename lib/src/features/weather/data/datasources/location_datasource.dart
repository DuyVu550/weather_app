import 'package:geolocator/geolocator.dart';

import '../../../../core/error/failures.dart';

class LocationDataSource {
  /// Xin quyền truy cập vị trí. Trả về [LocationPermission].
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Lấy vị trí hiện tại với độ chính xác cao.
  /// Ném [LocationFailure] nếu không lấy được.
  Future<Position> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw const LocationFailure('Không thể lấy vị trí hiện tại.');
    }
  }
}
