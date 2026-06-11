import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/saved_location.dart';
import 'geocoding_provider.dart';

class LocationSearchState {
  final bool isLoading;
  final List<SavedLocation> results;
  final String? error;

  LocationSearchState({
    this.isLoading = false,
    this.results = const [],
    this.error,
  });

  LocationSearchState copyWith({
    bool? isLoading,
    List<SavedLocation>? results,
    String? error,
  }) {
    return LocationSearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error,
    );
  }
}

class LocationSearchNotifier extends StateNotifier<LocationSearchState> {
  final Ref ref;

  LocationSearchNotifier(this.ref) : super(LocationSearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = LocationSearchState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = ref.read(geocodingRepositoryProvider);
      final results = await repo.searchLocations(query);
      state = state.copyWith(isLoading: false, results: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = LocationSearchState();
  }
}

final locationSearchProvider = StateNotifierProvider<LocationSearchNotifier, LocationSearchState>((ref) {
  return LocationSearchNotifier(ref);
});
