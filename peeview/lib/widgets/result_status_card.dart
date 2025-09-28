import 'package:flutter/material.dart';

class ResultStatusCard extends StatelessWidget {
  final String status;

  const ResultStatusCard({
    super.key,
    required this.status,
  });

  Color _getStatusColor() {
    switch (status) {
      case "DANGER":
        return Colors.red;
      case "WARNING":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getStatusColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Status: $status",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
