// lib/services/notification_service.dart
import 'package:firebase_core/firebase_core.dart'; // [QUAN TRỌNG] Để init Firebase khi app tắt
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // [SỬA] Dùng thư viện này để có debugPrint
import 'api_service.dart';

// [QUAN TRỌNG] Hàm xử lý khi App đang tắt (Background/Terminated)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Bắt buộc khởi tạo Firebase ở luồng background này
  await Firebase.initializeApp();
  debugPrint(
      "Đã nhận thông báo ngầm: ${message.messageId}"); // [SỬA] Dùng debugPrint
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Hàm khởi tạo
  Future<void> init(int userId) async {
    // 1. Xin quyền
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Quyền thông báo: ĐƯỢC PHÉP'); // [SỬA] Dùng debugPrint

      // 2. Đăng ký hàm xử lý chạy ngầm
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // 3. Lấy Token gửi lên Server
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint("FCM Token: $token");
        await ApiService.updateFcmToken(userId, token);
      }

      // 4. Lắng nghe khi Token thay đổi
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        ApiService.updateFcmToken(userId, newToken);
      });

      // 5. [Foreground] Lắng nghe tin nhắn khi App đang mở
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Nhận tin nhắn ForeGround: ${message.notification?.title}');

        if (message.notification != null) {
          debugPrint('Nội dung: ${message.notification!.body}');
        }
      });
    } else {
      debugPrint('Quyền thông báo: BỊ TỪ CHỐI');
    }
  }
}
