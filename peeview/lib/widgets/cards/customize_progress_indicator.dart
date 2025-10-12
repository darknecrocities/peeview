import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final int totalSteps = 5;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;

  const CustomProgressIndicator({
    Key? key,
    required this.currentStep,
    this.activeColor = const Color(0XFF0062C8),
    this.inactiveColor = const Color(0xFFe6e6e6),
    this.dotSize = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        bool isActive = index == currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}
