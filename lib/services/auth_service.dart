import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:loyalty/screen/auth/get_otp.dart';

class AuthService {
  static Future<void> signOut(BuildContext context) async {
    await InAppWebViewController.clearAllCache(); // Clear webview cache
    await CookieManager().deleteAllCookies(); // Delete webview cookies
    await DatabaseRepository().clearDatabase(); // Clear local user data

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const GetOtp();
        },
      ),
      (route) => false,
    );
  }
}
