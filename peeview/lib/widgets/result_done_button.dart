import 'package:flutter/material.dart';

class ResultDoneButton extends StatelessWidget {
  final VoidCallback onTap;

  const ResultDoneButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: const Text(
          "Done",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
