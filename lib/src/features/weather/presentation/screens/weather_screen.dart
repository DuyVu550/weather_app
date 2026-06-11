import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/weather.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_animation_helper.dart';
import 'location_management_screen.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ----------------------------------------------------------------
          // Nền gradient động — thay màu theo điều kiện thời tiết
          // ----------------------------------------------------------------
          _AnimatedBackground(weatherAsync: weatherAsync),

          // ----------------------------------------------------------------
          // Nội dung chính
          // ----------------------------------------------------------------
          SafeArea(
            child: weatherAsync.when(
              loading: () => const _LoadingView(),
              error: (error, _) => _ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(weatherProvider),
              ),
              data: (weather) => _WeatherDataView(weather: weather),
            ),
          ),
          // ----------------------------------------------------------------
          // Nút quản lý địa điểm
          // ----------------------------------------------------------------
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.list, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LocationManagementScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Nền gradient động
// ============================================================================
class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground({required this.weatherAsync});

  final AsyncValue<Weather> weatherAsync;

  List<Color> _resolveColors() {
    return weatherAsync.when(
      loading: () => [
        const Color(0xFF1a237e),
        const Color(0xFF283593),
        const Color(0xFF303f9f),
      ],
      error: (_, _) => [
        const Color(0xFF37474f),
        const Color(0xFF455a64),
        const Color(0xFF546e7a),
      ],
      data: (w) {
        final stops =
            WeatherAnimationHelper.gradientFromIconCode(w.iconCode);
        return stops.map((s) => Color(s.color)).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _resolveColors(),
        ),
      ),
    );
  }
}

// ============================================================================
// Trạng thái Loading — Lottie "not-available" + skeleton shimmer
// ============================================================================
class _LoadingView extends StatefulWidget {
  const _LoadingView();

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmerAnim = Tween<double>(begin: 0.25, end: 0.7).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        // Lottie loading animation
        Lottie.asset(
          'assets/animations/loading.json',
          width: 160,
          height: 160,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        const Text(
          'Đang lấy thông tin thời tiết…',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 40),
        // Skeleton shimmer
        AnimatedBuilder(
          animation: _shimmerAnim,
          builder: (context, _) => Opacity(
            opacity: _shimmerAnim.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _shimmerBar(width: 180, height: 18),
                  const SizedBox(height: 20),
                  _shimmerBar(width: 110, height: 72),
                  const SizedBox(height: 14),
                  _shimmerBar(width: 220, height: 16),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(child: _shimmerBar(height: 90)),
                      const SizedBox(width: 14),
                      Expanded(child: _shimmerBar(height: 90)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _shimmerBar(height: 90)),
                      const SizedBox(width: 14),
                      Expanded(child: _shimmerBar(height: 90)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _shimmerBar({double? width, double height = 16}) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
      );
}

// ============================================================================
// Trạng thái Error — đám mây bay lên xuống + nút Thử lại
// ============================================================================
class _ErrorView extends StatefulWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  State<_ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<_ErrorView>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation đám mây bay lên xuống
            AnimatedBuilder(
              animation: _floatAnim,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _floatAnim.value),
                child: child,
              ),
              child: Lottie.asset(
                'assets/animations/overcast.json',
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Rất tiếc!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 36),
            if (widget.message.contains('vĩnh viễn'))
              _GlassButton(
                label: '⚙️ Mở Cài đặt',
                onPressed: () {
                  Geolocator.openAppSettings();
                },
              )
            else
              _GlassButton(label: '🔄  Thử lại', onPressed: widget.onRetry),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Trạng thái Data — giao diện thời tiết đầy đủ
// ============================================================================
class _WeatherDataView extends ConsumerWidget {
  const _WeatherDataView({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lottieAsset =
        WeatherAnimationHelper.assetPathFromIconCode(weather.iconCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ---- Header: Thành phố + ngày ----
          _buildHeader(),

          const SizedBox(height: 24),

          // ---- Hero card: Lottie + nhiệt độ ----
          _GlassCard(
            child: Column(
              children: [
                // Lottie animation theo điều kiện thời tiết
                Lottie.asset(
                  lottieAsset,
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  repeat: true,
                ),

                // Nhiệt độ lớn
                Text(
                  '${weather.temperature.round()}°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 76,
                    fontWeight: FontWeight.w200,
                    height: 1,
                    letterSpacing: -3,
                  ),
                ),
                const SizedBox(height: 10),

                // Mô tả
                Text(
                  _capitalize(weather.description),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Cảm giác như
                Text(
                  'Cảm giác như ${weather.feelsLike.round()}°C',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ---- Grid chỉ số phụ ----
          _buildMetricsGrid(),

          const SizedBox(height: 24),
          
          // ---- Dự báo 5 ngày ----
          const _ForecastList(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_rounded, color: Colors.white70, size: 18),
            const SizedBox(width: 4),
            Text(
              '${weather.cityName}, ${weather.country}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _formattedDate(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    final items = [
      _MetricItem(
        lottieAsset: 'assets/animations/drizzle.json',
        icon: Icons.water_drop_rounded,
        label: 'Độ ẩm',
        value: '${weather.humidity}%',
        accentColor: const Color(0xFF64b5f6),
      ),
      _MetricItem(
        icon: Icons.air_rounded,
        label: 'Sức gió',
        value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
        accentColor: const Color(0xFF80cbc4),
      ),
      _MetricItem(
        icon: Icons.thermostat_rounded,
        label: 'Cảm giác',
        value: '${weather.feelsLike.round()}°C',
        accentColor: const Color(0xFFffb74d),
      ),
      _MetricItem(
        icon: Icons.wb_cloudy_rounded,
        label: 'Điều kiện',
        value: _capitalize(weather.description),
        accentColor: const Color(0xFFce93d8),
        smallText: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _MetricCard(item: items[i]),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _formattedDate() {
    final now = DateTime.now();
    const days = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
    final dayName = days[(now.weekday - 1) % 7];
    return '$dayName, ${now.day}/${now.month}/${now.year}';
  }
}

// ============================================================================
// Glass Card
// ============================================================================
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================================
// Metric Card — chỉ số phụ
// ============================================================================
class _MetricItem {
  final IconData icon;
  final String? lottieAsset;
  final String label;
  final String value;
  final Color accentColor;
  final bool smallText;

  const _MetricItem({
    required this.icon,
    this.lottieAsset,
    required this.label,
    required this.value,
    required this.accentColor,
    this.smallText = false,
  });
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.item});

  final _MetricItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon hoặc mini Lottie
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: item.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.accentColor, size: 20),
              ),

              // Giá trị + nhãn
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: item.smallText ? 13 : 20,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Glass Button
// ============================================================================
class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.5),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForecastList extends ConsumerWidget {
  const _ForecastList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastAsync = ref.watch(forecastProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Dự báo thời tiết (3 giờ / lần)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        forecastAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white54)),
          error: (error, _) => Center(child: Text('Lỗi: $error', style: const TextStyle(color: Colors.white70))),
          data: (forecast) {
            return SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.items.length,
                itemBuilder: (context, index) {
                  final item = forecast.items[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${item.dateTime.hour.toString().padLeft(2, '0')}:00',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          '${item.dateTime.day}/${item.dateTime.month}',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        Image.network(item.iconUrl, width: 40, height: 40, errorBuilder: (c, e, s) => const Icon(Icons.cloud, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          '${item.temperature.round()}°',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
