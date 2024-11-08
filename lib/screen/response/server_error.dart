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
              padding: const EdgeInsets.only(
                  top: 50.0, left: 50.0, right: 50.0, bottom: 50.0),
              child: Image.asset(
                'assets/images/503-error.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0), // Added horizontal padding
              child: Text(
                message,
                textAlign: TextAlign.center, // Center the text
                style:
                    const TextStyle(fontSize: 14.0), // Optional: Set font size
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
