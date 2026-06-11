# 🌤️ Ứng dụng Thời tiết Flutter (Flutter Weather App)

Một ứng dụng dự báo thời tiết đẹp mắt, mượt mà và hoạt động ổn định được xây dựng bằng Flutter. Dự án này áp dụng các tiêu chuẩn và best-practices mới nhất trong lập trình Flutter, bao gồm Kiến trúc Sạch (Clean Architecture), quản lý trạng thái với Riverpod và bao phủ toàn diện bởi Unit Test.

## ✨ Tính năng nổi bật

- **Thời tiết hiện tại**: Xem thông tin thời tiết theo thời gian thực dựa trên vị trí GPS của thiết bị.
- **Dự báo 5 ngày tới**: Xem biểu đồ dự báo chi tiết theo chu kỳ 3 giờ cho 5 ngày tiếp theo.
- **Quản lý địa điểm**: Tìm kiếm và lưu trữ danh sách các thành phố yêu thích để dễ dàng theo dõi thời tiết ở mọi nơi.
- **Giao diện động (Dynamic UI)**: Hình nền và hoạt ảnh thay đổi tự động dựa vào tình hình thời tiết thực tế (sử dụng Lottie và hiệu ứng kính mờ - Glassmorphism).
- **Xử lý lỗi mạnh mẽ**: Xử lý mượt mà các tình huống mất mạng, từ chối quyền GPS, hoặc lỗi từ máy chủ API với cơ chế cho phép thử lại (retry) thân thiện với người dùng.

## 🛠️ Công nghệ sử dụng

- **Framework**: [Flutter](https://flutter.dev/)
- **Quản lý trạng thái (State Management)**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
- **Kiến trúc (Architecture)**: Clean Architecture (Gồm 3 tầng: Presentation, Domain, Data)
- **Networking API**: Gói thư viện `http`
- **Định vị GPS**: `geolocator`
- **Lưu trữ cục bộ (Local Storage)**: `shared_preferences`
- **Hoạt ảnh (Animations)**: `lottie`
- **Kiểm thử (Testing)**: `mockito`, `flutter_test`

## 📁 Cấu trúc thư mục dự án

Dự án tuân theo chuẩn **Feature-First Clean Architecture** (Kiến trúc Sạch chia theo Tính năng):

```text
lib/
├── src/
│   └── features/
│       └── weather/
│           ├── data/             # Models, Data Sources (Remote/Local), Repositories Impl
│           ├── domain/           # Entities, Repositories Interfaces, Use Cases
│           └── presentation/     # Screens, Widgets, Riverpod Providers
└── main.dart
```

## 🚀 Hướng dẫn cài đặt

### Yêu cầu hệ thống

1. Cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Lấy API Key miễn phí từ [OpenWeatherMap](https://openweathermap.org/api).

### Các bước chạy ứng dụng

1. Điều hướng vào thư mục dự án:
   ```bash
   cd weather_app
   ```
2. Cài đặt các gói thư viện phụ thuộc:
   ```bash
   flutter pub get
   ```
3. Khởi chạy ứng dụng (trên máy ảo hoặc thiết bị thật):
   ```bash
   flutter run
   ```

*(Lưu ý: Ứng dụng yêu cầu quyền truy cập Vị trí (GPS) để tải thời tiết mặc định. Hãy đảm bảo tính năng Location Services được bật trên thiết bị/máy ảo của bạn).*

## 🧪 Kiểm thử (Testing)

Dự án có sẵn một bộ Unit Test chi tiết, kiểm thử toàn bộ từ Models, DataSources, Repositories, UseCases cho đến Providers.

Để chạy tất cả các bài kiểm thử:
```bash
flutter test
```

Hiện tại, dự án đạt mức độ **vượt qua kiểm thử 100% (34/34 tests pass)**.

## 🎨 Giao diện & Trải nghiệm (UI / UX)

- **Hiệu ứng Kính (Glassmorphism)**: Các thẻ thông tin trong suốt, sang trọng nằm trên các dải màu (gradient) năng động.
- **Hoạt ảnh Lottie (Lottie Integration)**: Các hoạt ảnh vector chất lượng cao mô tả sinh động trạng thái thời tiết (vd: nắng, mưa, nhiều mây).
- **Thiết kế thích ứng (Responsive)**: Tương thích với nhiều kích cỡ màn hình khác nhau và xử lý linh hoạt phần khuyết màn hình (notch) hoặc khi bật bàn phím ảo.

---
*Phát triển với Flutter & ❤️*
