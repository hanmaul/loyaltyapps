import 'package:flutter/material.dart';

class WebViewErrorPage extends StatelessWidget {
  final String type;
  final String message; // Error message to display
  final String imagePath; // Path to the error image (dynamic)
  final VoidCallback onRetry; // Retry callback function

  const WebViewErrorPage({
    super.key,
    required this.type,
    required this.message,
    required this.imagePath,
    required this.onRetry,
  });

  // Method to return button text based on error type
  String textButton() {
    if (type == 'not_found') {
      return 'Kembali';
    } else {
      return 'Coba Lagi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(50),
              child: Image.asset(
                imagePath, // Dynamically load the image based on the error type
                fit: BoxFit.cover,
              ),
            ),
            Text(message),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry, // Dynamically handle the retry action
              child: Text(textButton()), // Call the textButton method properly
            ),
          ],
        ),
      ),
    );
  }
}
