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

Dự án tuân theo chuẩn **Kiến trúc Sạch (Clean Architecture)** được chia theo từng tính năng (Feature-first). Việc chia nhỏ này giúp mã nguồn dễ đọc, dễ bảo trì và tái sử dụng:

```text
lib/
├── main.dart                     # Điểm bắt đầu (Entry point) khởi chạy ứng dụng
└── src/
    ├── core/                     # Chứa các thành phần cốt lõi dùng chung cho toàn dự án
    │   ├── error/                # Các class định nghĩa lỗi (Failure, Exceptions)
    │   └── utils/                # Các hằng số (Constants), cấu hình chung (API Key, Base URL)
    └── features/
        └── weather/              # Tính năng thời tiết (chia theo mô hình Clean Architecture)
            ├── data/             # TẦNG DỮ LIỆU: Quản lý việc lấy và xử lý dữ liệu thô
            │   ├── datasources/  #   - Nơi gọi API (http) hoặc đọc từ bộ nhớ tạm (SharedPreferences)
            │   ├── models/       #   - Nơi chứa các class phục vụ parse JSON từ API (Kế thừa Entities)
            │   └── repositories/ #   - Nơi triển khai (Implementation) các logic lấy dữ liệu cụ thể
            ├── domain/           # TẦNG NGHIỆP VỤ: Trái tim của ứng dụng, không phụ thuộc vào framework
            │   ├── entities/     #   - Các đối tượng dữ liệu thuần túy (Weather, Forecast, Location)
            │   ├── repositories/ #   - Các Interface (hợp đồng) định nghĩa phương thức lấy dữ liệu
            │   └── usecases/     #   - Nơi chứa logic nghiệp vụ cụ thể (Ví dụ: GetWeatherUseCase)
            └── presentation/     # TẦNG GIAO DIỆN: Nơi hiển thị thông tin và tương tác với người dùng
                ├── providers/    #   - Các file quản lý trạng thái bằng Riverpod (Riverpod State)
                ├── screens/      #   - Các màn hình UI của ứng dụng (WeatherScreen, LocationScreen)
                └── utils/        #   - Các tiện ích nhỏ dành riêng cho UI (như helper cho animation Lottie)
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
