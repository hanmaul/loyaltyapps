import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:loyalty/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseApi {
  // create an instance of Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  // funtion to initialize notifications
  Future<void> initNotifications() async {
    // reqyest permission from user (will prompt user)
    await _firebaseMessaging.requestPermission();

    // fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();

    // print the token (normally you would send this to your server)
    print('Token: $fCMToken');

    // save token in session
    saveToken(fCMToken.toString());

    // initialize further settings for push notif
    initPushNotifications();
  }

  void saveToken(String token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("firebaseToken", token);
  }

  // funtion to handle received messages
  void handleMessage(RemoteMessage? message) {
    // if the message is null, do nothing
    if (message == null) return;

    // navigate to new screen when messages is received and user taps notifications
    navigatorKey.currentState?.pushNamed(
      '/notifikasi',
      arguments: message,
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
