import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ScanResultScreen extends StatelessWidget {
  final Map<String, dynamic> results;

  const ScanResultScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final aiInsights = results["aiInsights"] ?? "No insights generated.";
    final suggestedAction =
        results["suggestedAction"] ?? "No action provided.";
    final diseasePrediction = results["diseasePrediction"] ?? {};
    final int ckdProbability = diseasePrediction["ckdProbability"] ?? 0;
    final int nonCkdProbability = diseasePrediction["nonCkdProbability"] ?? 100;
    final String status = results["status"] ?? "LOW";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "peeView Test Result",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟦 Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E63D0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("peeView Test Result",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("October 5, 2025  •  10:15 PM",
                          style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: status == "HIGH"
                          ? Colors.red
                          : status == "MODERATE"
                          ? Colors.orange
                          : Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🟩 AI Insights
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 6),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("AI Insights",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1E63D0))),
                  const SizedBox(height: 12),
                  Text(aiInsights,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                          fontSize: 14, height: 1.5, color: Colors.black87)),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 14, height: 1.5, color: Colors.black87),
                      children: [
                        const TextSpan(
                            text: "Suggested Action: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        TextSpan(text: suggestedAction),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 📅 Schedule Button
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                side: const BorderSide(color: Color(0xFF1E63D0)),
              ),
              child: const Text("SCHEDULE A CONSULTATION",
                  style: TextStyle(color: Color(0xFF1E63D0))),
            ),
            const SizedBox(height: 16),

            // 🟥 Disease Prediction
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 6),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Disease Prediction",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  CircularPercentIndicator(
                    radius: 60,
                    lineWidth: 12,
                    percent: ckdProbability / 100,
                    center: Text("$ckdProbability%",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    progressColor: Colors.red,
                    backgroundColor: Colors.grey[200]!,
                  ),
                  const SizedBox(height: 8),
                  const Text("Chronic Kidney Disease (CKD)"),
                  const SizedBox(height: 12),
                  Text("Non-CKD: $nonCkdProbability%",
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text("Probability",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

