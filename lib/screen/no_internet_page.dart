import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          // This will center the Column itself
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(top: 50.0, left: 50.0, right: 50.0),
                child: Image.asset(
                  'assets/images/No connection-rafiki.png',
                  fit: BoxFit.cover,
                ),
              ),
              Text('No Internet Connection..'),
            ],
          ),
        ),
      ),
    );
  }
}
