import 'package:flutter/material.dart';

class CustomizeNextButton extends StatelessWidget {
  final Color color;
  final double size;
  final VoidCallback? onPressed;

  CustomizeNextButton({
    super.key,
    this.color = const Color(0XFF0062C8),
    this.size = 18.0,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(Icons.arrow_forward, color: Colors.white, size: size),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
