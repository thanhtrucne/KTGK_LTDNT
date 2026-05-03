import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService(this._messaging);

  final FirebaseMessaging _messaging;

  Future<void> init() async {
    // iOS can xin quyen hien notification; Android 13+ cung can permission.
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('Nguoi dung da cap quyen thong bao.');
    }

    // Lay FCM Token de gui thong bao tu backend (neu can)
    final token = await _messaging.getToken();
    log('FCM Token: $token');

    // Lang nghe tin nhan khi ung dung dang o foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Nhan thong bao moi (Foreground): ${message.notification?.title}');
      // O day co the hien thi mot dialog hoac snackbar tuy chinh
    });

    // Lang nghe khi nguoi dung bam vao thong bao de mo app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Nguoi dung da bam vao thong bao: ${message.data}');
    });
  }
}
