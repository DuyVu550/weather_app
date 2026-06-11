import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/location.dart';
import '../../../../core/error/failures.dart';

/// Provider cung cấp [AsyncValue<Location>].
/// Tự động xin quyền rồi lấy tọa độ khi được khởi tạo.
final locationProvider = FutureProvider<Location>((ref) async {
  // 1. Kiểm tra xem dịch vụ vị trí có được bật không.
  final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!isServiceEnabled) {
    throw const LocationFailure(
      'Dịch vụ vị trí đang bị tắt. Vui lòng bật GPS.',
    );
  }

  // 2. Kiểm tra và xin quyền truy cập vị trí.
  // Geolocator dùng LocationPermission thay vì PermissionStatus.
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw const LocationFailure('Quyền truy cập vị trí đã bị từ chối.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw const LocationFailure(
      'Quyền truy cập vị trí bị từ chối vĩnh viễn. '
      'Vui lòng mở Cài đặt để cấp quyền.',
    );
  }

  try {
    // 3. Lấy tọa độ hiện tại.
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );

    return Location(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  } catch (e) {
    // Nếu bị timeout hoặc lỗi, thử lấy vị trí gần nhất đã biết (rất hữu ích trên Emulator)
    final lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null) {
      return Location(
        latitude: lastPosition.latitude,
        longitude: lastPosition.longitude,
      );
    }
    
    throw const LocationFailure('Không thể lấy được vị trí hiện tại. Vui lòng thử lại.');
  }
});
