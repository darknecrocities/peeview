import 'package:flutter/material.dart';

class ResultChart extends StatelessWidget {
  const ResultChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          "📊 Chart Placeholder",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
