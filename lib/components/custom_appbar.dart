import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            spreadRadius: 5, // Spread radius
            blurRadius: 10, // Blur radius
            offset: const Offset(0, 2), // Offset
          ),
        ],
      ),
      child: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        title: Container(
          margin: const EdgeInsets.only(top: 16, left: 4),
          child: RichText(
            text: TextSpan(
              text: "Hai, ",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.only(top: 14, right: 14),
              child: const Icon(
                Icons.manage_search_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ],
        backgroundColor: const Color(0xff0B60B0),
      ),
    );
  }
}
