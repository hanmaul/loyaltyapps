import 'package:flutter/widgets.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/main.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForLogout();
    }
  }

  // Function to check if the user exists
  Future<void> _checkForLogout() async {
    bool userExists = await DatabaseRepository().checkUserExists();

    if (!userExists) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          navigatorKey.currentContext!,
          '/get-otp',
          (route) => false,
        );
      });
    }
  }
}
