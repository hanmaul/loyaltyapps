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
      await DatabaseRepository().saveLogoutSession(
          "You were logged out because your account was used on another device.");
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

  static Future<void> signOutByUser(BuildContext context) async {
    await InAppWebViewController.clearAllCache(); // Clear WebView cache
    await CookieManager().deleteAllCookies(); // Delete WebView cookies
    await DatabaseRepository().clearDatabase();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const GetOtp()),
      (route) => false,
    );
  }

  static Future<void> checkForLogoutSession(BuildContext context) async {
    // Check if there is a logout session stored
    final logoutSession = await DatabaseRepository().getLogoutSession();
    if (logoutSession != null) {
      // Show a dialog explaining the logout
      _showLogoutSessionDialog(context, logoutSession.reason);
    }
  }

  // Show the logout session dialog
  static void _showLogoutSessionDialog(BuildContext context, String reason) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Logged Out"),
            content: Text(reason),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  // Clear the logout session after the user acknowledges it
                  await DatabaseRepository().clearLogoutSession();
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    });
  }
}
