import 'package:flutter/services.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel('com.aidocapp/notifications');

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'title': title,
        'body': body,
        'payload': payload,
      });
    } on PlatformException catch (e) {
      print('Error showing notification: ${e.message}');
    }
  }

  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      print('Error initializing notifications: ${e.message}');
    }
  }
} 