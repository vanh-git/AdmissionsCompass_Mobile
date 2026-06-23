# Cấu hình Numerology, Firebase Credits và PayOS

## Kiến trúc

Flutter không lưu khóa bí mật PayOS. Ứng dụng chỉ:

1. Gọi `POST {PAYOS_API_BASE_URL}/api/pc`.
2. Tạo document `payment_orders/{orderCode}` trạng thái `PENDING`.
3. Hiển thị VietQR hoặc mở `checkoutUrl`.
4. Lắng nghe document cho đến khi webhook đặt trạng thái `PAID`.
5. Đọc credits từ `users/{uid}.credits`.

Backend phải xác thực webhook, cộng credits và ghi transaction.

## Biến môi trường backend

Thiết lập trên Vercel hoặc nền tảng triển khai API:

```text
APP_URL=https://domain-production-cua-ban
PAYOS_CLIENT_ID=...
PAYOS_API_KEY=...
PAYOS_CHECKSUM_KEY=...
VITE_FIREBASE_API_KEY=...
VITE_FIREBASE_PROJECT_ID=exe-labantuyensinh
```

Không đặt ba khóa `PAYOS_*` trong Flutter hoặc commit vào Git.

## Chạy Flutter với backend khác

Mặc định ứng dụng gọi:

```text
https://labantuyensinh.vercel.app
```

Để đổi backend:

```powershell
.\.tools\flutter\bin\flutter.bat run -d chrome `
  --dart-define=PAYOS_API_BASE_URL=https://api.example.com
```

Build production:

```powershell
.\.tools\flutter\bin\flutter.bat build web --release `
  --dart-define=PAYOS_API_BASE_URL=https://api.example.com
```

## PayOS Dashboard

Đăng ký webhook:

```text
https://domain-production-cua-ban/api/payos-webhook
```

Webhook cần trả HTTP 200 và kiểm tra signature bằng `PAYOS_CHECKSUM_KEY`.

## Firestore schema

```text
users/{uid}
  credits: number
  totalPurchased: number

users/{uid}/transactions/{transactionId}
  credits: number
  method: "payos"
  priceVnd: number
  orderCode: string
  createdAt: timestamp

payment_orders/{orderCode}
  uid: string
  packageId: string
  credits: number
  amount: number
  status: "PENDING" | "PAID"
  credited: boolean
  createdAt: timestamp
  paidAt: timestamp
```

## Lưu ý bảo mật quan trọng

Webhook hiện tại của website đăng nhập Firebase ẩn danh và cập nhật Firestore
qua REST. Cách này buộc Firestore Rules phải cấp quyền ghi quá rộng và không phù
hợp production.

Nên chuyển webhook sang Firebase Admin SDK bằng service account:

- Webhook/Admin SDK là bên duy nhất được tăng credits.
- Client chỉ được giảm `credits` đúng 1 đơn vị trong transaction.
- Client chỉ được tạo đơn `PENDING` cho chính UID của mình.
- Client không được đặt `status = PAID` hoặc `credited = true`.
- Không cho client tự tạo transaction thanh toán.

Nếu chưa chuyển sang Admin SDK, không nên mở thanh toán thật cho người dùng.
