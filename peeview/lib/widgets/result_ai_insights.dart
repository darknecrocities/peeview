import 'package:flutter/material.dart';

class ResultAiInsights extends StatelessWidget {
  final String insights;

  const ResultAiInsights({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          insights,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
