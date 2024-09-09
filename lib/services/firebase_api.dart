import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:loyalty/main.dart';
import 'package:flutter/material.dart';
import 'package:loyalty/services/auth_service.dart';
import 'package:http/http.dart' as http;

// Background message handler
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  if (message.data['action'] == 'logout') {
    await AuthService.clearSession();
  }
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Function to initialize notifications
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(); // Request permission
    initPushNotifications(); // Initialize further settings
  }

  Future<String> fetchFCM() async {
    final fcmToken = await _firebaseMessaging.getToken();
    return fcmToken.toString(); // Fetch FCM token for this device
  }

  Future<bool> validateToken(
      {required String key,
      required String custId,
      required bool forceLogout}) async {
    String fToken = await fetchFCM();
    final baseUrl =
        "https://www.kamm-group.com:8070/fapi/checkfirebase?key=$key";

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'cust_id': custId,
        'id_firebase': fToken,
        'force_logout': forceLogout.toString(),
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.isNotEmpty && jsonResponse[0]['status'] == true;
    } else {
      debugPrint('Request failed with status: ${response.statusCode}');
      return false;
    }
  }

  // Handle received messages
  void handleMessage(RemoteMessage? message) {
    if (message == null || message.data.isEmpty) return;

    final action = message.data['action'];

    switch (action) {
      case 'logout':
        _forceLogout();
        break;
      case 'home':
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
        break;
      default:
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/notifications',
          (route) => false,
        );
    }
  }

  // Force logout
  void _forceLogout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService.signOut(navigatorKey.currentContext!); // Sign out user
    });
  }

  // Initialize foreground and background settings
  Future<void> initPushNotifications() async {
    // Handle notifications if the app was terminated and is now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // Handle notification when the app is in the background and the user taps it
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // Handle notification when app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleMessage(message); // Handle foreground message
    });

    // Handle notification when app is in the background (onBackgroundMessage)
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);
  }
}
