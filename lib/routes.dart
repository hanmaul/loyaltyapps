import 'package:flutter/material.dart';
import 'package:loyalty/screen/auth/auth.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:loyalty/screen/notifications.dart';
import 'package:loyalty/screen/webview/akunku.dart';
import 'package:loyalty/screen/webview/services.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:loyalty/screen/webview/keuangan.dart';
import 'package:loyalty/screen/webview/promo.dart';

Map<String, WidgetBuilder> routes = {
  '/': (context) => const Auth(),
  '/dashboard': (context) => const Dashboard(),
  '/account': (context) => const Akunku(),
  '/services': (context) => const WebviewServices(),
  '/keuangan': (context) => const WebviewKeuangan(),
  '/register': (context) => const Register(),
  '/promo': (context) => const WebviewPromo(),
  '/notifikasi': (context) => const Notifications(),
};
