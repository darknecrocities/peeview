import 'package:flutter/material.dart';

class ResultHeader extends StatelessWidget {
  final String userName;

  const ResultHeader({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // ✅ removed stray x
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Hello, $userName 👋",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
