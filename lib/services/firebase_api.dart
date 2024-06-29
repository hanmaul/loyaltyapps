import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:loyalty/main.dart';
import 'package:loyalty/data/repository/database_repository.dart';

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

  Future<void> getFCM() async {
    // fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();

    // save token in storage
    await DatabaseRepository()
        .updateUser(field: 'firebaseToken', data: fCMToken.toString());
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
