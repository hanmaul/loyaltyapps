import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:loyalty/main.dart';
import 'package:flutter/material.dart';
import 'package:loyalty/services/auth_service.dart';
import 'package:http/http.dart' as http;

// This top-level function will handle messages in the background
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  if (message.data['action'] == 'logout') {
    print("Background message received: Logout action triggered");
    // Ensure the context is provided correctly for navigation or sign out
    WidgetsFlutterBinding.ensureInitialized();
    AuthService.signOut(
        navigatorKey.currentContext!); // Call the logout function
  }
}

class FirebaseApi {
  // create an instance of Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  // funtion to initialize notifications
  Future<void> initNotifications() async {
    // request permission from user (will prompt user)
    await _firebaseMessaging.requestPermission();

    // initialize further settings for push notif
    initPushNotifications();
  }

  Future<String> fetchFCM() async {
    // fetch the FCM token for this device
    final fcmToken = await _firebaseMessaging.getToken();
    String token = fcmToken.toString();
    return token;
  }

  Future<bool> validateToken(
      {required String key, required String custId}) async {
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
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.isNotEmpty && jsonResponse[0]['status'] == true) {
        return true;
      } else {
        return false;
      }
    } else {
      debugPrint('Request failed with status: ${response.statusCode}');
      return false;
    }
  }

  // funtion to handle received messages
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    if (message.data['action'] == 'logout') {
      _forceLogout(); // Force the user to log out
    }

    print('Message Title: ${message.notification?.title}');
    print('Message Body: ${message.notification?.body}');
  }

  // Force logout
  void _forceLogout() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      AuthService.signOut(navigatorKey.currentContext!); // Sign out user
    });
  }

  // funtion to initialize foreground and background settings
  Future initPushNotifications() async {
    // handle notifications if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // attach event listeners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
