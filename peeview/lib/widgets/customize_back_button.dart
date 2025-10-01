// customize_back_button.dart
import 'package:flutter/material.dart';

class CustomizeBackButton extends StatelessWidget {
  final Color color;
  final double size;
  final VoidCallback? onPressed;

  const CustomizeBackButton({
    super.key,
    this.color = Colors.grey,
    this.size = 24.0,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: color, size: size),
        onPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }
}
