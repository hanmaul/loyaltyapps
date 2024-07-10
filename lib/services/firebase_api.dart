import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:loyalty/main.dart';
import 'package:http/http.dart' as http;

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
    // if the message is null, do nothing

    if (message == null) {
      return;
    } else {
      print('Title : ${message.notification!.title.toString()}');
      print('Body : ${message.notification!.body.toString()}');
    }

    // navigate to new screen when messages is received and user taps notifications
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/notifications',
      (route) => false,
    );
  }

  // funtion to initialize foreground and background settings
  Future initPushNotifications() async {
    // handle notifications if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // attach event listeners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
