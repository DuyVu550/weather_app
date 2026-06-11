import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  // Read API Key from .env file
  static String get openWeatherMapApiKey {
    if (dotenv.isInitialized) {
      return dotenv.env['OPEN_WEATHER_API_KEY'] ?? '';
    }
    return 'test_api_key'; // Fallback for unit tests
  }
  static const String openWeatherMapBaseUrl = 'api.openweathermap.org';
}
