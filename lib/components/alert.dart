import 'package:flutter/material.dart';

class MyAlert extends StatelessWidget {
  final String title;
  final String content;
  final String type;
  final List<Widget>? actions;

  const MyAlert({
    Key? key,
    required this.title,
    required this.content,
    required this.type,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color titleColor;
    switch (type) {
      case 'error':
        titleColor = Colors.red;
        break;
      case 'warning':
        titleColor = Colors.yellow;
        break;
      default:
        titleColor = Colors.black;
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        title,
        style: TextStyle(color: titleColor, fontSize: 20),
      ),
      content: Text.rich(
        TextSpan(
          text: content,
          style: const TextStyle(
            // fontSize: 15,
            height: 1.5, // Adjust the line height as needed
          ),
        ),
      ),
      actions: actions ?? [], // Dynamic actions
    );
  }
}

void showAlert({
  required BuildContext context,
  required String title,
  required String content,
  required String type,
  List<Widget>? actions, // Optional actions
  bool barierDismiss = true,
}) {
  showDialog(
    barrierDismissible: barierDismiss,
    context: context,
    builder: (context) {
      return MyAlert(
        title: title,
        content: content,
        type: type,
        actions: actions,
      );
    },
  );
}
