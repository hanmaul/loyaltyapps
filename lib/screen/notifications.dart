import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:loyalty/screen/no_internet_page.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  // Widget build(BuildContext context) {
  //   final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
  //
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text(
  //         "Notifications",
  //         style: TextStyle(
  //           fontWeight: FontWeight.w500,
  //           color: Colors.white,
  //         ),
  //       ),
  //       backgroundColor: const Color(0xff0B60B0),
  //     ),
  //     backgroundColor: Colors.white,
  //     body: Center(
  //       child: message != null
  //           ? Text(message.notification!.body.toString())
  //           : const Text('Under Constructions..'),
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
    return InternetAwareWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Notifications",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xff0B60B0),
        ),
        backgroundColor: Colors.white,
        body: const Center(
          child: Text('Under Constructions..'),
        ),
      ),
    );
  }
}
