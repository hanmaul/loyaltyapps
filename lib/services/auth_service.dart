import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:loyalty/screen/auth/get_otp.dart';

class AuthService {
  // Background logout logic without UI navigation
  static Future<void> signOutInBackground() async {
    await InAppWebViewController.clearAllCache(); // Clear WebView cache
    await CookieManager().deleteAllCookies(); // Delete WebView cookies
    await DatabaseRepository().clearDatabase(); // Clear local user data
    print("User has been logged out in background");
  }

  // Foreground logout logic with navigation
  static Future<void> signOut(BuildContext context) async {
    await InAppWebViewController.clearAllCache(); // Clear WebView cache
    await CookieManager().deleteAllCookies(); // Delete WebView cookies
    await DatabaseRepository().clearDatabase(); // Clear local user data

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const GetOtp(); // Navigate to OTP screen after logout
        },
      ),
      (route) => false,
    );
  }
}
