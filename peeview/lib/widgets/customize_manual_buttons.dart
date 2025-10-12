import 'package:flutter/material.dart';

class CustomizeManualButtons extends StatelessWidget {
  final VoidCallback onNext; // for Next button
  final Widget nextScreen; // for Skip navigation
  final String skipLabel;
  final String nextLabel;
  final Color skipColor;
  final Color nextColor;

  const CustomizeManualButtons({
    super.key,
    required this.onNext,
    required this.nextScreen,
    this.skipLabel = "Skip",
    this.nextLabel = "Next",
    this.skipColor = const Color(0xFFe6e6e6),
    this.nextColor = const Color(0XFF0062C8),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Skip button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => nextScreen),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: skipColor,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              skipLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Next button
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: nextColor,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              nextLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
