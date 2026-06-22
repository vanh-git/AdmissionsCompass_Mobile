# Admissions Compass Mobile

Ứng dụng Flutter tư vấn tuyển sinh, gồm đăng nhập Firebase, trắc nghiệm
RIASEC, thần số học và chat cộng đồng.

## Chạy nhanh trên web

Flutter stable đã được đặt cục bộ tại `.tools/flutter`.

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\run_web.ps1
```

Hoặc chạy thủ công:

```powershell
.\.tools\flutter\bin\flutter.bat pub get
.\.tools\flutter\bin\flutter.bat run -d chrome
```

## Kiểm tra source

```powershell
.\.tools\flutter\bin\flutter.bat analyze
.\.tools\flutter\bin\flutter.bat test
```

## Android

Thư mục `C:\Users\ttphatt_2403\.android` chỉ chứa cấu hình ADB, không phải
Android SDK. Cần cài Android Studio cùng Android SDK, sau đó chạy:

```powershell
.\.tools\flutter\bin\flutter.bat config --android-sdk "C:\Users\ttphatt_2403\AppData\Local\Android\Sdk"
.\.tools\flutter\bin\flutter.bat doctor --android-licenses
.\.tools\flutter\bin\flutter.bat doctor -v
```

Cấu hình Firebase Android/iOS trong `lib/firebase_options.dart` hiện vẫn chứa
`PLACEHOLDER`. Hãy chạy `flutterfire configure` với project Firebase chính xác
trước khi chạy bản native. Cấu hình web hiện đã có đầy đủ thông tin.

## Ghi chú môi trường Windows

Flutter plugin cần quyền tạo symbolic link. Bật **Developer Mode** trong
Windows Settings > Privacy & security > For developers nếu Flutter báo lỗi
`Building with plugins requires symlink support`.
