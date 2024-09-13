import 'package:flutter/widgets.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:loyalty/services/auth_service.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  DatabaseRepository databaseRepository = DatabaseRepository();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForLogout();
    }
  }

// Function to check if the user exists and route is not '/get-otp'
  Future<void> _checkForLogout() async {
    final logoutSession = await databaseRepository.getLogoutSession();
    bool keyExists = true; // Initialize keyExists to avoid null issues

    final custId = await databaseRepository.loadUser(field: 'custId');
    final key = await databaseRepository.loadUser(field: 'key');
    keyExists = await AuthService.keyExists(custId: custId, key: key);

    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());

    // Only proceed with logout check if the device is connected to the internet
    if (connectivityResult != ConnectivityResult.none) {
      // If the logout session exists or the key doesn't exist, perform actions
      if (logoutSession != null || !keyExists) {
        // Clear session if the key doesn't exist
        if (!keyExists) {
          await AuthService.clearSession();
        }

        // Navigate to '/get-otp'
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
