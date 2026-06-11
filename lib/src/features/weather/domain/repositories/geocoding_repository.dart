import '../entities/saved_location.dart';

abstract class GeocodingRepository {
  /// Tìm kiếm địa điểm theo tên, trả về danh sách các kết quả phù hợp.
  Future<List<SavedLocation>> searchLocations(String query);
}
