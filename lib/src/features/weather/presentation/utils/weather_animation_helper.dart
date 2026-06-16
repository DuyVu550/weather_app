/// Ánh xạ từ icon code của OpenWeatherMap sang file Lottie tương ứng.
///
/// OpenWeatherMap icon codes:
///   01d / 01n  → trời quang (nắng / đêm rõ)
///   02d / 02n  → ít mây
///   03d / 03n  → mây rải rác
///   04d / 04n  → mây nhiều
///   09d / 09n  → mưa phùn
///   10d / 10n  → mưa
///   11d / 11n  → dông bão
///   13d / 13n  → tuyết
///   50d / 50n  → sương mù / mù
class WeatherAnimationHelper {
  WeatherAnimationHelper._();

  /// Trả về đường dẫn asset của Lottie JSON tương ứng với [iconCode] và [description] (tùy chọn).
  static String assetPathFromIconCode(String iconCode, [String? description]) {
    final code = iconCode.replaceAll(RegExp(r'[dn]$'), ''); // bỏ suffix d/n
    final isHail = description != null && 
        (description.toLowerCase().contains('hail') || description.toLowerCase().contains('mưa đá'));
    
    if (isHail) {
      return 'assets/animations/hail.json';
    }
    switch (code) {
      case '01':
        return iconCode.endsWith('n')
            ? 'assets/animations/clear_night.json'
            : 'assets/animations/sunny.json';
      case '02':
        return 'assets/animations/partly_cloudy.json';
      case '03':
        return 'assets/animations/cloudy.json';
      case '04':
        return 'assets/animations/overcast.json';
      case '09':
        return 'assets/animations/drizzle.json';
      case '10':
        return 'assets/animations/rain.json';
      case '11':
        return 'assets/animations/thunder.json';
      case '13':
        return 'assets/animations/snow.json';
      case '50':
        return 'assets/animations/mist.json';
      default:
        return 'assets/animations/sunny.json';
    }
  }

  /// Màu nền gradient tương ứng với từng điều kiện thời tiết.
  static List<({double stop, int color})> gradientFromIconCode(String iconCode) {
    final code = iconCode.replaceAll(RegExp(r'[dn]$'), '');
    final isNight = iconCode.endsWith('n');

    if (isNight) {
      return [
        (stop: 0.0, color: 0xFF0a0e27),
        (stop: 0.5, color: 0xFF1a1f4a),
        (stop: 1.0, color: 0xFF2d2d6b),
      ];
    }

    switch (code) {
      case '01': // Nắng to
        return [
          (stop: 0.0, color: 0xFFff8c00),
          (stop: 0.5, color: 0xFFff6b35),
          (stop: 1.0, color: 0xFF1565c0),
        ];
      case '02':
      case '03': // Ít mây / mây rải rác
        return [
          (stop: 0.0, color: 0xFF1565c0),
          (stop: 0.5, color: 0xFF1976d2),
          (stop: 1.0, color: 0xFF64b5f6),
        ];
      case '04': // Nhiều mây
        return [
          (stop: 0.0, color: 0xFF455a64),
          (stop: 0.5, color: 0xFF546e7a),
          (stop: 1.0, color: 0xFF78909c),
        ];
      case '09':
      case '10': // Mưa
        return [
          (stop: 0.0, color: 0xFF1a237e),
          (stop: 0.5, color: 0xFF283593),
          (stop: 1.0, color: 0xFF3949ab),
        ];
      case '11': // Dông bão
        return [
          (stop: 0.0, color: 0xFF1b1b2f),
          (stop: 0.5, color: 0xFF2c2c54),
          (stop: 1.0, color: 0xFF474787),
        ];
      case '13': // Tuyết
        return [
          (stop: 0.0, color: 0xFF90caf9),
          (stop: 0.5, color: 0xFFbbdefb),
          (stop: 1.0, color: 0xFFe3f2fd),
        ];
      case '50': // Sương mù
        return [
          (stop: 0.0, color: 0xFF78909c),
          (stop: 0.5, color: 0xFF90a4ae),
          (stop: 1.0, color: 0xFFb0bec5),
        ];
      default:
        return [
          (stop: 0.0, color: 0xFF0d47a1),
          (stop: 0.5, color: 0xFF1565c0),
          (stop: 1.0, color: 0xFF42a5f5),
        ];
    }
  }
}
