import '../entities/saved_location.dart';

abstract class LocalLocationRepository {
  /// Lấy danh sách các địa điểm đã lưu.
  Future<List<SavedLocation>> getSavedLocations();

  /// Thêm một địa điểm mới vào danh sách.
  Future<void> saveLocation(SavedLocation location);

  /// Xóa một địa điểm khỏi danh sách theo ID.
  Future<void> removeLocation(String id);
}
