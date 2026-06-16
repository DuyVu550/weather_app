import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/src/features/weather/presentation/providers/settings_provider.dart';
import 'package:weather_app/src/features/weather/presentation/providers/saved_locations_provider.dart';

void main() {
  test('SettingsProvider toggles temperature unit', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(settingsProvider.notifier);
    
    // Initial state
    expect(container.read(settingsProvider).temperatureUnit, TemperatureUnit.celsius);
    
    // Toggle
    await notifier.toggleTemperatureUnit();
    expect(container.read(settingsProvider).temperatureUnit, TemperatureUnit.fahrenheit);
    expect(prefs.getBool('temperature_unit'), true);
    
    // Toggle back
    await notifier.toggleTemperatureUnit();
    expect(container.read(settingsProvider).temperatureUnit, TemperatureUnit.celsius);
    expect(prefs.getBool('temperature_unit'), false);
  });
}
