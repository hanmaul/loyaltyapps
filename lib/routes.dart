import 'package:flutter/material.dart';
import 'package:loyalty/screen/auth/auth.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:loyalty/screen/notifications.dart';
import 'package:loyalty/screen/webview/akunku.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:loyalty/screen/webview/content.dart';

Map<String, WidgetBuilder> routes = {
  '/': (context) => const Auth(),
  '/dashboard': (context) => const Dashboard(),
  // '/account': (context) => const Akunku(),
  // '/register': (context) => const Register(),
  '/notifikasi': (context) => const Notifications(),
  '/content': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    return Content(title: args['title']!, url: args['url']!);
  },
};
