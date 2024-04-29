import 'package:flutter/material.dart';

class ServerError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ServerError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: 50.0, left: 50.0, right: 50.0, bottom: 50.0),
              child: Image.asset(
                'assets/images/503 Error Service Unavailable-rafiki.png',
                fit: BoxFit.cover,
              ),
            ),
            Text(message),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
