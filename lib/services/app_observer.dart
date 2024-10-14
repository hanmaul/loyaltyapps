import 'package:flutter/widgets.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/main.dart';
import 'package:loyalty/services/auth_service.dart';
import 'package:loyalty/services/internet_service.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  DatabaseRepository databaseRepository = DatabaseRepository();
  InternetService internetService = InternetService();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForLogout();
    }
  }

// Function to check if the user exists and route is not '/get-otp'
  Future<void> _checkForLogout() async {
    final logoutSession = await databaseRepository.getLogoutSession();
    final hasInternet = await internetService.hasActiveInternetConnection();

    // Only proceed with logout check if the device is connected to the internet
    if (hasInternet) {
      bool keyExists =
          true; // Initialize keyExists as true to avoid null issues
      final custId = await databaseRepository.loadUser(field: 'custId');
      final key = await databaseRepository.loadUser(field: 'key');

      if (custId.isNotEmpty && key.isNotEmpty) {
        // Perform keyExists check only when there is an active internet connection
        keyExists = await AuthService.keyExists(custId: custId, key: key);
      }

      // If the logout session exists or the key doesn't exist, navigate to '/get-otp'
      if (logoutSession != null || !keyExists) {
        // Clear session if the key doesn't exist
        if (!keyExists) {
          await AuthService.clearSession();
        }

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
