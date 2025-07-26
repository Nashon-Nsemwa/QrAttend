import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Call this after user logs in and role & userId are saved in GetStorage
  static Future<void> initialize() async {
    await _configureLocalNotifications();
    await _configureFCMHandlers();

    // Save token now
    await _saveDeviceToken();

    // Listen for token refresh and update Firestore accordingly
    _handleTokenRefresh();
  }

  static Future<void> requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
      '🔔 Notification permission status: ${settings.authorizationStatus}',
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('🚫 User declined notification permissions');
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted full notification permissions');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('🟡 User granted provisional permissions');
    }
  }

  static Future<void> _configureLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final screen = response.payload;
        if (screen == 'announcement') {
          Get.toNamed('/Notification');
        }
      },
    );
  }

  static Future<void> _configureFCMHandlers() async {
    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
      debugPrint('📥 Foreground notification: ${message.notification?.title}');
    });

    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🟡 Opened from background tap');
      _handleNotificationTap(message.data);
    });

    // Terminated tap
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🔵 Opened from terminated tap');
      _handleNotificationTap(initialMessage.data);
    }
  }

  // helper function to handle navigation
  static void _handleNotificationTap(Map<String, dynamic> data) {
    final screen = data['screen'];

    if (screen == 'announcement') {
      Get.toNamed('/Notification');
    } else {
      debugPrint('🔕 Unknown screen in payload: $screen');
    }
  }

  static void _showLocalNotification(RemoteMessage message) {
    final androidDetails = AndroidNotificationDetails(
      'qrattend_notifications', //channel ID
      'QrAttend Notifications', //channel Name
      channelDescription: 'Used for receiving push notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      notificationDetails,
      payload: message.data['screen'], // <-- for specific screen navigation
    );
  }

  /// Save the device FCM token to Firestore under student's or lecture's document
  static Future<void> _saveDeviceToken() async {
    final storage = GetStorage();
    final user = _auth.currentUser;
    if (user == null) return;

    final role = storage.read<String>('role');
    if (role == null) {
      debugPrint('Role not found in GetStorage, cannot save token.');
      return;
    }

    final token = await _firebaseMessaging.getToken();
    if (token == null) {
      debugPrint('FCM token is null, cannot save.');
      return;
    }

    final collection = role == 'student' ? 'students' : 'lectures';

    try {
      await _firestore.collection(collection).doc(user.uid).update({
        'fcmToken': token,
      });
      debugPrint('✅ Token saved in $collection/${user.uid}');
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  /// Listen for token refresh events and update Firestore
  static void _handleTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final storage = GetStorage();
      final user = _auth.currentUser;
      if (user == null) return;

      final role = storage.read<String>('role');
      if (role == null) {
        debugPrint('Role not found in GetStorage, cannot update token.');
        return;
      }

      final collection = role == 'student' ? 'students' : 'lectures';

      try {
        await _firestore.collection(collection).doc(user.uid).update({
          'fcmToken': newToken,
        });
        debugPrint('♻️ Token refreshed and updated in Firestore');
      } catch (e) {
        debugPrint('Error updating refreshed token: $e');
      }
    });
  }

  /// Call this on user sign out to remove token from Firestore
  static Future<void> clearTokenOnSignOut() async {
    final storage = GetStorage();
    final user = _auth.currentUser;
    if (user == null) return;

    final role = storage.read<String>('role');
    if (role == null) {
      debugPrint('Role not found in GetStorage, cannot clear token.');
      return;
    }

    final collection = role == 'student' ? 'students' : 'lectures';

    try {
      await _firestore.collection(collection).doc(user.uid).update({
        'fcmToken': FieldValue.delete(),
      });
      debugPrint('🚪 Token removed on sign out');
    } catch (e) {
      debugPrint('Error deleting token on sign out: $e');
    }
  }
}
