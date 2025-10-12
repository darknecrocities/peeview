import 'package:flutter/material.dart';

class CustomizeSkipButton extends StatelessWidget {
  final Widget nextScreen;

  const CustomizeSkipButton({super.key, required this.nextScreen});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      },

      child: const Text(
        "Skip",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
