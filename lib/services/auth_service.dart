import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:loyalty/components/alert.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/auth/get_otp.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Background logout logic without UI navigation
  static Future<void> clearSession() async {
    bool userExists = await DatabaseRepository().checkUserExists();
    if (userExists) {
      await InAppWebViewController.clearAllCache(); // Clear WebView cache
      await CookieManager().deleteAllCookies(); // Delete WebView cookies
      await DatabaseRepository().clearDatabase(); // Clear local user data
      await DatabaseRepository().saveLogoutSession(
          "Anda telah keluar karena akun Anda digunakan di perangkat lain.");
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
      // Clear session logout
      await DatabaseRepository().clearLogoutSession();
      // Show a dialog explaining the logout
      _showLogoutSessionDialog(context, logoutSession.reason);
    }
  }

  // Show the logout session dialog
  static void _showLogoutSessionDialog(BuildContext context, String reason) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAlert(
        barierDismiss: false,
        context: context,
        title: 'Keluar Akun',
        content: reason,
        type: 'error',
        actions: [
          TextButton(
            child: const Text(
              'OK',
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  static Future<bool> keyExists(
      {required String custId, required String key}) async {
    const baseUrl = "https://www.kamm-group.com:8070/fapi/checkkey";

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'cust_id': custId,
        'key': key,
      }),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.isNotEmpty && jsonResponse[0]['status'] == true;
    } else {
      debugPrint('Request failed with status: ${response.statusCode}');
      return false;
    }
  }
}
