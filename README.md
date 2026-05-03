# 🌍 Đồ án: Travel Planner - Ứng dụng Lập kế hoạch Du lịch

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-60B5FF?style=for-the-badge&logo=dart&logoColor=white)](https://riverpod.dev)

Đây là đồ án kết thúc học phần cho môn **Lập trình Di động Nâng cao (LTDNT)**. Ứng dụng **Travel Planner** là một giải pháp toàn diện giúp người dùng quản lý, lên kế hoạch và lưu giữ những kỷ niệm cho mỗi chuyến hành trình.

---

## ✨ Tính năng chính

### 🔐 Hệ thống Xác thực & Người dùng
- **Đa phương thức đăng nhập:** Hỗ trợ Email/Password, **Google Sign-In**, và xác thực qua **Số điện thoại (OTP)**.
- **Quản lý Profile:** Cập nhật thông tin cá nhân, lưu trữ ảnh đại diện trực tiếp trên Firestore dưới dạng chuỗi Base64 (tối ưu tốc độ tải và quản lý).

### 📍 Quản lý Chuyến đi (Trips)
- **Danh sách thông minh:** Phân loại chuyến đi theo trạng thái: *Sắp tới (Upcoming), Đang diễn ra (Ongoing), và Đã hoàn thành (Completed)*.
- **Tìm kiếm & Lọc:** Tìm kiếm chuyến đi nhanh chóng theo tên hoặc địa điểm.
- **Đa phương tiện:** Tích hợp hình ảnh đại diện cho mỗi chuyến đi để dễ dàng nhận diện.

### 📝 Lập kế hoạch chi tiết
- **Lịch trình (Activities):** Lên kế hoạch chi tiết từng hoạt động, địa điểm tham quan cho từng ngày trong chuyến đi.
- **Danh sách chuẩn bị (Checklist):** Quản lý các vật dụng cần mang theo, đảm bảo không bỏ sót bất kỳ thứ gì.
- **Quản lý Chi phí (Expenses):** Theo dõi ngân sách dự kiến và ghi chép các khoản chi tiêu thực tế một cách trực quan.
- **Khoảnh khắc (Trip Moments):** Lưu lại những bức ảnh và cảm xúc đáng nhớ trong suốt hành trình.

### 🎨 Trải nghiệm người dùng (UX/UI)
- **Giao diện hiện đại:** Thiết kế theo chuẩn **Material 3** với ngôn ngữ thiết kế tối giản, sang trọng.
- **Dark Mode:** Hỗ trợ giao diện tối toàn diện, tự động thích ứng hoặc tùy chỉnh theo sở thích.
- **Hiệu ứng & Chuyển động:** Sử dụng `flutter_animate` để tạo các vi tương tác (micro-interactions) mượt mà.
- **Offline First:** Hỗ trợ lưu trữ đệm (Firestore persistence) giúp người dùng xem lại dữ liệu ngay cả khi không có kết nối mạng.

---

## 🛠️ Công nghệ sử dụng

- **Framework:** [Flutter](https://flutter.dev) (SDK ^3.11.4)
- **State Management:** [Riverpod](https://riverpod.dev) & [Provider](https://pub.dev/packages/provider)
- **Backend:** [Firebase](https://firebase.google.com) (Auth, Firestore, Cloud Messaging)
- **Database:** Cloud Firestore (Real-time synchronization)
- **Fonts:** Google Fonts (Poppins)
- **Icons:** Cupertino Icons, Lucide Icons (Custom widgets)

---

## 📂 Cấu trúc mã nguồn

```text
lib/
├── models/         # Định nghĩa các thực thể (Trip, Activity, Expense, ChecklistItem...)
├── providers/      # Quản lý trạng thái ứng dụng (Auth, Theme, Trip State...)
├── screens/        # Giao diện người dùng phân theo Module (Auth, Trips, Profile...)
├── services/       # Lớp xử lý logic nghiệp vụ và tương tác Firebase API
├── utils/          # Các hàm tiện ích, định dạng và kiểm tra dữ liệu (Validators)
└── widgets/        # Các thành phần UI dùng chung (Buttons, Cards, EmptyStates...)
```

---

## 🚀 Hướng dẫn cài đặt & Chạy dự án

### 1. Yêu cầu hệ thống
- Flutter SDK đã được cài đặt.
- Firebase CLI & FlutterFire CLI.

### 2. Cấu hình Firebase
Ứng dụng yêu cầu tệp `google-services.json` (Android) và `GoogleService-Info.plist` (iOS). Để tự động cấu hình, hãy chạy:
```bash
flutterfire configure
```

### 3. Cài đặt Dependencies
```bash
flutter pub get
```

### 4. Chạy ứng dụng
```bash
flutter run
```

---

## 👨‍💻 Thông tin đồ án
- **Sinh viên thực hiện:** Thanh Trúc (@thanhtrucne)
- **Môn học:** Lập trình Di động Nâng cao (LTDNT)

---
*Dự án này được xây dựng với mục tiêu thực hành các kỹ năng lập trình Flutter nâng cao và tích hợp dịch vụ Cloud cho ứng dụng di động.*
