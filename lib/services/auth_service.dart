import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/auth/get_otp.dart';

class AuthService {
  // Background logout logic without UI navigation
  static Future<void> clearSession() async {
    bool userExists = await DatabaseRepository().checkUserExists();
    if (userExists) {
      await InAppWebViewController.clearAllCache(); // Clear WebView cache
      await CookieManager().deleteAllCookies(); // Delete WebView cookies
      await DatabaseRepository().clearDatabase(); // Clear local user data
    }
  }

  // Foreground logout logic with navigation
  static Future<void> signOut(BuildContext context) async {
    await clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const GetOtp()),
      (route) => false,
    );
  }
}
