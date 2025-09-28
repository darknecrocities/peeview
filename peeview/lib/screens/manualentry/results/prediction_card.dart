import 'package:flutter/material.dart';

class PredictionCard extends StatelessWidget {
  final double ckdProbability; // raw score
  final double nonCkdProbability; // raw score

  // Parsed numeric lab values (defaults to 0)
  final int wbc;
  final int bacteria;
  final int transparency;
  final int protein;

  const PredictionCard({
    super.key,
    required this.ckdProbability,
    required this.nonCkdProbability,
    this.wbc = 0,
    this.bacteria = 0,
    this.transparency = 0,
    this.protein = 0,
  });

  /// Normalized CKD percentage (0–100)
  int get ckdPct {
    final total = ckdProbability + nonCkdProbability;
    if (total <= 0) return 0;
    return ((ckdProbability / total) * 100).round();
  }

  /// Normalized Non-CKD percentage (0–100)
  int get nonCkdPct {
    final total = ckdProbability + nonCkdProbability;
    if (total <= 0) return 0;
    return ((nonCkdProbability / total) * 100).round();
  }

  String get status {
    final bool critical = wbc > 6 || bacteria > 5 || protein > 1 || transparency > 5;
    if (critical) return "HIGH";

    if (ckdPct >= 70) return "HIGH";
    if (ckdPct >= 40) return "WARNING";
    return "HEALTHY";
  }

  Color get statusColor {
    if (status == "HIGH") return const Color(0xFFB71C1C); // red
    if (status == "WARNING") return const Color(0xFFF57C00); // orange
    return const Color(0xFF2E7D32); // green
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Disease Prediction",
            style: TextStyle(
              color: Color(0xFF0057D9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular indicator
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: ckdPct / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$ckdPct%",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB71C1C),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "CKD Risk",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 22),

              // Right side: legend + status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB71C1C),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Chronic Kidney Disease (CKD)",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          "$ckdPct%",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Non-CKD",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        Text(
                          "$nonCkdPct%",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (status == "HIGH")
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          _explainWhy(),
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 26),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.shade400, blurRadius: 6, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _explainWhy() {
    final reasons = <String>[];
    if (wbc > 6) reasons.add("WBC elevated");
    if (bacteria > 5) reasons.add("Bacteria high");
    if (protein > 1) reasons.add("Protein present");
    if (transparency > 5) reasons.add("Transparency hazy");
    if (reasons.isEmpty) {
      if (ckdPct >= 70) return "Model predicts high CKD risk.";
      if (ckdPct >= 40) return "Model suggests possible risk.";
      return "No clear abnormalities detected.";
    }
    return reasons.join(", ") + ".";
  }
}
