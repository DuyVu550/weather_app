import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/saved_location.dart';

class GeocodingRemoteDataSource {
  final http.Client client;

  GeocodingRemoteDataSource({required this.client});

  Future<List<SavedLocation>> searchLocations(String query) async {
    final uri = Uri.https(
      Constants.openWeatherMapBaseUrl,
      '/geo/1.0/direct',
      {
        'q': query,
        'limit': '5',
        'appid': Constants.openWeatherMapApiKey,
      },
    );

    http.Response response;
    try {
      response = await client.get(uri);
    } catch (e) {
      throw const NetworkFailure('Không có kết nối Internet.');
    }

    if (response.statusCode == 401) {
      throw const ServerFailure('API Key không hợp lệ hoặc đã hết hạn.');
    } else if (response.statusCode == 429) {
      throw const ServerFailure('Đã vượt quá giới hạn gọi API.');
    } else if (response.statusCode != 200) {
      throw ServerFailure('Lỗi máy chủ (${response.statusCode})');
    }

    final List<dynamic> jsonList = json.decode(response.body);
    
    return jsonList.map((item) {
      final map = item as Map<String, dynamic>;
      final lat = (map['lat'] as num).toDouble();
      final lon = (map['lon'] as num).toDouble();
      return SavedLocation(
        id: '${lat}_${lon}',
        name: map['name'] as String,
        country: map['country'] as String? ?? '',
        latitude: lat,
        longitude: lon,
      );
    }).toList();
  }
}
