# Hướng dẫn cấu hình Firebase cho dự án

Dự án này sử dụng Firebase để quản lý xác thực (Authentication), lưu trữ dữ liệu (Firestore) và thông báo đẩy (Cloud Messaging). Để chạy được ứng dụng, bạn cần thực hiện các bước cấu hình sau:

## 1. Tạo dự án trên Firebase Console
- Truy cập [Firebase Console](https://console.firebase.google.com/).
- Bấm "Add project" và đặt tên cho dự án của bạn.

## 2. Cấu hình các dịch vụ
### Authentication:
- Bật **Email/Password**.
- Bật **Google** (Cần cung cấp SHA-1 cho Android).
- Bật **Phone** (Để sử dụng OTP).

### Cloud Firestore:
- Tạo database ở chế độ **Test Mode** (hoặc cấu hình Rules phù hợp).
- Tạo collection `users` và `employees`.

## 3. Cài đặt FlutterFire CLI
Để tự động tạo file `firebase_options.dart`, hãy chạy các lệnh sau trong terminal tại thư mục gốc của dự án:

```bash
# Cài đặt CLI nếu chưa có
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Cấu hình dự án (Đảm bảo đã đăng nhập: firebase login)
flutterfire configure
```

Lệnh `flutterfire configure` sẽ tự động:
- Đăng ký ứng dụng Android & iOS với Firebase.
- Tải các file cấu hình (`google-services.json`, `GoogleService-Info.plist`).
- Tạo file `lib/firebase_options.dart`.

## 4. Cấu hình riêng cho Android (Google Sign-In & OTP)
- Truy cập Project Settings trên Firebase Console.
- Thêm **SHA-1 fingerprint** của máy bạn vào ứng dụng Android.
  - Lấy SHA-1 bằng lệnh: `./gradlew signingReport` (trong thư mục `android`).

## 5. Cấu hình riêng cho iOS (Google Sign-In)
- Mở file `ios/Runner/Info.plist`.
- Thêm `CFBundleURLTypes` để xử lý Google Sign-In (lấy `REVERSED_CLIENT_ID` từ file `GoogleService-Info.plist` sau khi chạy `flutterfire configure`).

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## 6. Chạy ứng dụng
Sau khi đã cấu hình xong, hãy chạy lệnh sau để cài đặt dependencies và khởi động app:

```bash
flutter pub get
flutter run
```

---
*Lưu ý: Nếu bạn gặp lỗi về index trong Firestore khi tìm kiếm, hãy bấm vào link đính kèm trong log của terminal/debug console để Firebase tự động tạo index cần thiết.*
