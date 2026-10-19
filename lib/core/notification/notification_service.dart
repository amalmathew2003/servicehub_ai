
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;
  String? _activeUserId;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _notificationTapSubscription;

  /// Request notification permission and initialize FCM listeners.
  Future<String?> initialize() async {
    if (_initialized) {
      return _messaging.getToken();
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Notification permission denied.');
      return null;
    }

    final token = await _messaging.getToken();

    debugPrint('FCM token: $token');

    // Listen for notifications received while the app is open.
    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'Foreground notification title: '
        '${message.notification?.title}',
      );
      debugPrint(
        'Foreground notification body: '
        '${message.notification?.body}',
      );
      debugPrint('Notification data: ${message.data}');
    });

    // Listen when the user taps a notification.
    _notificationTapSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        debugPrint('Notification tapped: ${message.data}');

        // Booking navigation will be connected in the next step.
      },
    );

    // Keep the active user's token updated when it changes.
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      (String newToken) async {
        debugPrint('FCM token refreshed.');

        final userId = _activeUserId;

        if (userId != null) {
          await _saveToken(userId, newToken);
        }
      },
      onError: (Object error) {
        debugPrint('FCM token refresh error: $error');
      },
    );

    _initialized = true;

    return token;
  }

  /// Register the FCM token for the authenticated user's Firestore document.
  ///
  /// Call this after authentication confirms the user's role is "staff".
  Future<void> registerStaffToken({
    required String staffId,
  }) async {
    if (staffId.trim().isEmpty) {
      debugPrint('Cannot register FCM token: staff ID is empty.');
      return;
    }

    _activeUserId = staffId;

    try {
      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('FCM token is not available yet.');
        return;
      }

      await _saveToken(staffId, token);

      debugPrint('FCM token saved for staff: $staffId');
    } catch (e, stackTrace) {
      debugPrint('Failed to save staff FCM token: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save the token in the signed-in user's document.
  Future<void> _saveToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).set(
      {
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Get a notification that opened the app from a terminated state.
  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  /// Listen for FCM token changes.
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Stop listeners when the service is no longer needed.
  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _notificationTapSubscription?.cancel();
  }
}
