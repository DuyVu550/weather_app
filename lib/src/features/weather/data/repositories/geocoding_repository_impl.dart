import '../../domain/entities/saved_location.dart';
import '../../domain/repositories/geocoding_repository.dart';
import '../datasources/geocoding_remote_datasource.dart';

class GeocodingRepositoryImpl implements GeocodingRepository {
  final GeocodingRemoteDataSource remoteDataSource;

  GeocodingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SavedLocation>> searchLocations(String query) {
    return remoteDataSource.searchLocations(query);
  }
}
