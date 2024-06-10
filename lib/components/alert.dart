import 'package:flutter/material.dart';

class MyAlert extends StatelessWidget {
  final String title;
  final String content;
  final String type;

  const MyAlert({
    Key? key,
    required this.title,
    required this.content,
    required this.type,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        title,
        style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
      ),
      content: Text(
        content,
        style: TextStyle(color: Colors.grey[700]),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'OK',
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

void showAlert({
  required BuildContext context,
  required String title,
  required String content,
  required String type,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Theme(
        data: ThemeData(dialogBackgroundColor: Colors.white),
        child: MyAlert(
          title: title,
          content: content,
          type: type,
        ),
      );
    },
  );
}
