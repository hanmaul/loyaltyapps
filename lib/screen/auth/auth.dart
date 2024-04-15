import 'package:flutter/material.dart';
import 'package:loyalty/screen/auth/get_otp.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loyalty/screen/introduction.dart';
import 'package:loyalty/screen/dashboard.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  String key = "";
  String nama = "";

  void sessionCheck() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      key = pref.getString("key")!;
      nama = pref.getString("nama")!;
    });
  }

  @override
  void initState() {
    sessionCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          if (key != "" && nama != "") {
            return const Dashboard();
          } else if (key != "" && nama == "") {
            return const Register();
          } else {
            // return Introduction(); --> User Baru
            return const getOtp();
          }
        },
      ),
    );
  }
}
