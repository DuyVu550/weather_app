import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/src/features/weather/presentation/utils/weather_animation_helper.dart';

void main() {
  group('WeatherAnimationHelper', () {
    test('returns hail.json if description contains hail or mưa đá', () {
      expect(WeatherAnimationHelper.assetPathFromIconCode('13d', 'hail storm'), 'assets/animations/hail.json');
      expect(WeatherAnimationHelper.assetPathFromIconCode('13d', 'mưa đá'), 'assets/animations/hail.json');
      expect(WeatherAnimationHelper.assetPathFromIconCode('13d', 'Mưa Đá nhỏ'), 'assets/animations/hail.json');
    });

    test('returns standard json if description is null or different', () {
      expect(WeatherAnimationHelper.assetPathFromIconCode('01d'), 'assets/animations/sunny.json');
      expect(WeatherAnimationHelper.assetPathFromIconCode('01n'), 'assets/animations/clear_night.json');
      expect(WeatherAnimationHelper.assetPathFromIconCode('13d', 'light snow'), 'assets/animations/snow.json');
    });
  });
}
