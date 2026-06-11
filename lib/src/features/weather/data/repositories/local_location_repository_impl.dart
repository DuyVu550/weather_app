import '../../domain/entities/saved_location.dart';
import '../../domain/repositories/local_location_repository.dart';
import '../datasources/location_local_datasource.dart';

class LocalLocationRepositoryImpl implements LocalLocationRepository {
  final LocationLocalDataSource localDataSource;

  LocalLocationRepositoryImpl({required this.localDataSource});

  @override
  Future<List<SavedLocation>> getSavedLocations() {
    return localDataSource.getSavedLocations();
  }

  @override
  Future<void> removeLocation(String id) {
    return localDataSource.removeLocation(id);
  }

  @override
  Future<void> saveLocation(SavedLocation location) {
    return localDataSource.saveLocation(location);
  }
}
