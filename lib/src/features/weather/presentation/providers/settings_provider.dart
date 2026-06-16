import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'saved_locations_provider.dart';

enum TemperatureUnit { celsius, fahrenheit }

class SettingsState {
  final TemperatureUnit temperatureUnit;

  SettingsState({this.temperatureUnit = TemperatureUnit.celsius});

  SettingsState copyWith({TemperatureUnit? temperatureUnit}) {
    return SettingsState(
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref ref;
  static const _tempUnitKey = 'temperature_unit';

  SettingsNotifier(this.ref) : super(SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final prefs = ref.read(sharedPreferencesProvider);
    final isFahrenheit = prefs.getBool(_tempUnitKey) ?? false;
    state = state.copyWith(
      temperatureUnit: isFahrenheit ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius,
    );
  }

  Future<void> toggleTemperatureUnit() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final newUnit = state.temperatureUnit == TemperatureUnit.celsius
        ? TemperatureUnit.fahrenheit
        : TemperatureUnit.celsius;
    
    await prefs.setBool(_tempUnitKey, newUnit == TemperatureUnit.fahrenheit);
    state = state.copyWith(temperatureUnit: newUnit);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});
