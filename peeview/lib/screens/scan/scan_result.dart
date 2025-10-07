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

    Color getStatusColor() {
      switch (status.toUpperCase()) {
        case "HIGH":
          return Colors.red;
        case "MODERATE":
          return Colors.orange;
        default:
          return Colors.green;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "peeView Test Result",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🟦 Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E63D0), Color(0xFF3A82F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 10)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "peeView Test Result",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text("October 5, 2025  •  10:15 PM",
                          style:
                          TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🧠 AI Insights Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
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
                  Text(
                    aiInsights,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 14),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 15, color: Colors.black87, height: 1.5),
                      children: [
                        const TextSpan(
                            text: "Suggested Action: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E63D0))),
                        TextSpan(text: suggestedAction),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 📅 Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  side: const BorderSide(color: Color(0xFF1E63D0), width: 1.5),
                ),
                child: const Text("SCHEDULE A CONSULTATION",
                    style: TextStyle(
                        color: Color(0xFF1E63D0),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(height: 22),

            // 🔵 Disease Prediction Card
            Container(
              padding: const EdgeInsets.all(22),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text("Disease Prediction",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black87)),
                  const SizedBox(height: 18),
                  CircularPercentIndicator(
                    radius: 70,
                    lineWidth: 12,
                    animation: true,
                    animationDuration: 1200,
                    percent: ckdProbability / 100,
                    center: Text(
                      "$ckdProbability%",
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    progressColor: Colors.redAccent,
                    backgroundColor: Colors.grey.shade200,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Chronic Kidney Disease (CKD)",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Text("Non-CKD: $nonCkdProbability%",
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  const Text("Probability",
                      style:
                      TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
