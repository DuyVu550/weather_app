import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/geocoding_remote_datasource.dart';
import '../../data/repositories/geocoding_repository_impl.dart';
import '../../domain/repositories/geocoding_repository.dart';
import 'weather_provider.dart';

final geocodingRemoteDataSourceProvider = Provider<GeocodingRemoteDataSource>((ref) {
  return GeocodingRemoteDataSource(client: ref.watch(httpClientProvider));
});

final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  return GeocodingRepositoryImpl(remoteDataSource: ref.watch(geocodingRemoteDataSourceProvider));
});
