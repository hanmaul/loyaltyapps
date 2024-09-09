import 'package:flutter/widgets.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForLogout();
    }
  }

  // Function to check if the user exists and route is not '/get-otp'
  Future<void> _checkForLogout() async {
    bool userExists = await DatabaseRepository().checkUserExists();
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());

    // Only proceed with logout check if the device is connected to the internet
    if (connectivityResult != ConnectivityResult.none) {
      // Get the current route
      String? currentRoute =
          ModalRoute.of(navigatorKey.currentContext!)?.settings.name;

      // If the user doesn't exist and current route is not '/get-otp', navigate to '/get-otp'
      if (!userExists && currentRoute != '/get-otp') {
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
}
