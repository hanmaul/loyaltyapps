import 'package:flutter/material.dart';
import 'package:loyalty/screen/auth/get_otp.dart';
import 'package:loyalty/screen/auth/send_otp.dart';
import 'package:loyalty/screen/dashboard/dashboard.dart';
import 'package:loyalty/screen/auth/auth.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  if (settings.name!.startsWith('/send-otp/')) {
    final phone = settings.name!.split('/').last;
    return MaterialPageRoute(
      builder: (_) => SendOtp(phoneNumber: phone),
    );
  }

  switch (settings.name) {
    case '/dashboard':
      final args = settings.arguments as int;
      return MaterialPageRoute(
        builder: (_) => Dashboard(page: args),
      );
    case '/get-otp':
      return MaterialPageRoute(
        builder: (_) => const GetOtp(),
      );
    case '/home':
      return MaterialPageRoute(
        builder: (_) => const Dashboard(page: 0),
      );
    case '/history':
      return MaterialPageRoute(
        builder: (_) => const Dashboard(page: 1),
      );
    case '/notifications':
      return MaterialPageRoute(
        builder: (_) => const Dashboard(page: 2),
      );
    case '/account':
      return MaterialPageRoute(
        builder: (_) => const Dashboard(page: 3),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => const Auth(),
      );
  }
}
