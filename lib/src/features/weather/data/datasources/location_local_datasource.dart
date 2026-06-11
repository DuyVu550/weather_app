import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/saved_location.dart';

class LocationLocalDataSource {
  static const String _locationsKey = 'SAVED_LOCATIONS';
  final SharedPreferences sharedPreferences;

  LocationLocalDataSource({required this.sharedPreferences});

  Future<List<SavedLocation>> getSavedLocations() async {
    final jsonStringList = sharedPreferences.getStringList(_locationsKey) ?? [];
    
    return jsonStringList.map((jsonStr) {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return SavedLocation.fromJson(map);
    }).toList();
  }

  Future<void> saveLocation(SavedLocation location) async {
    final locations = await getSavedLocations();
    // Tránh lưu trùng lặp
    if (!locations.any((loc) => loc.id == location.id)) {
      locations.add(location);
      final jsonStringList = locations.map((loc) => json.encode(loc.toJson())).toList();
      await sharedPreferences.setStringList(_locationsKey, jsonStringList);
    }
  }

  Future<void> removeLocation(String id) async {
    final locations = await getSavedLocations();
    locations.removeWhere((loc) => loc.id == id);
    
    final jsonStringList = locations.map((loc) => json.encode(loc.toJson())).toList();
    await sharedPreferences.setStringList(_locationsKey, jsonStringList);
  }
}
