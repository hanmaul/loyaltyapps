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
    final logoutSession = await DatabaseRepository().getLogoutSession();

    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());

    // Only proceed with logout check if the device is connected to the internet
    if (connectivityResult != ConnectivityResult.none) {
      // If the logout session exist navigate to '/get-otp'
      if (logoutSession != null) {
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
