import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/location_local_datasource.dart';
import '../../data/repositories/local_location_repository_impl.dart';
import '../../domain/entities/saved_location.dart';
import '../../domain/repositories/local_location_repository.dart';

// --- Infrastructure ---

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

final locationLocalDataSourceProvider = Provider<LocationLocalDataSource>((ref) {
  return LocationLocalDataSource(sharedPreferences: ref.watch(sharedPreferencesProvider));
});

final localLocationRepositoryProvider = Provider<LocalLocationRepository>((ref) {
  return LocalLocationRepositoryImpl(localDataSource: ref.watch(locationLocalDataSourceProvider));
});

// --- State Management ---

class SavedLocationsState {
  final List<SavedLocation> locations;
  final SavedLocation? selectedLocation; // null = use GPS

  SavedLocationsState({
    this.locations = const [],
    this.selectedLocation,
  });

  SavedLocationsState copyWith({
    List<SavedLocation>? locations,
    SavedLocation? selectedLocation,
    bool clearSelected = false,
  }) {
    return SavedLocationsState(
      locations: locations ?? this.locations,
      selectedLocation: clearSelected ? null : (selectedLocation ?? this.selectedLocation),
    );
  }
}

class SavedLocationsNotifier extends StateNotifier<SavedLocationsState> {
  final LocalLocationRepository _repository;

  SavedLocationsNotifier(this._repository) : super(SavedLocationsState()) {
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final locs = await _repository.getSavedLocations();
    state = state.copyWith(locations: locs);
  }

  Future<void> addLocation(SavedLocation location) async {
    await _repository.saveLocation(location);
    await _loadLocations();
    selectLocation(location);
  }

  Future<void> removeLocation(String id) async {
    await _repository.removeLocation(id);
    if (state.selectedLocation?.id == id) {
      selectGPS();
    }
    await _loadLocations();
  }

  void selectLocation(SavedLocation location) {
    state = state.copyWith(selectedLocation: location);
  }

  void selectGPS() {
    state = state.copyWith(clearSelected: true);
  }
}

final savedLocationsProvider = StateNotifierProvider<SavedLocationsNotifier, SavedLocationsState>((ref) {
  return SavedLocationsNotifier(ref.watch(localLocationRepositoryProvider));
});
