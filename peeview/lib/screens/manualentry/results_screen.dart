import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/customize_navbar.dart';

class ResultsScreen extends StatefulWidget {
  final String sessionId;

  const ResultsScreen({super.key, required this.sessionId});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  String? geminiAnalysis;
  Map<String, dynamic>? testData;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAndAnalyze();
  }

  Future<void> _fetchAndAnalyze() async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection("urine_tests").doc(widget.sessionId).get();

      if (!doc.exists) {
        setState(() {
          isLoading = false;
          geminiAnalysis = "No test data found.";
        });
        return;
      }

      testData = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
      testData = testData!.map((key, value) {
        if (value is Timestamp) {
          return MapEntry(key, value.toDate().toIso8601String());
        }
        return MapEntry(key, value);
      });

      String prompt = """
You are a healthcare assistant analyzing urine test results.

Data: ${jsonEncode(testData)}

Write a short, structured summary with 3 sections only:
1. Key Insights – 2 concise points about what the results show.
2. Recommendations – 2 short tips for better health.
3. Risks – 1–2 possible health risks to monitor.

Keep sentences simple, max 12 words each. No long explanations.
""";

      final response = await http.post(
        Uri.parse(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyCOQKMmQuGYy0E4deGIOn6A9LFZ3TGP6GA"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List parts = data["candidates"]?[0]?["content"]?["parts"] ?? [];
        String output = parts.map((p) => p["text"]).join("\n");

        setState(() {
          geminiAnalysis =
          output.isNotEmpty ? output : "No insights generated.";
          isLoading = false;
        });
      } else {
        setState(() {
          geminiAnalysis =
          "Error from Gemini API: ${response.statusCode}\n${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        geminiAnalysis = "Error: $e";
        isLoading = false;
      });
    }
  }

  /// ---- AI Insights Builder ----
  Widget _buildInsights() {
    if (geminiAnalysis == null || geminiAnalysis!.isEmpty) {
      return const Text("No analysis available.");
    }

    // Split by numbered sections (1., 2., 3.)
    List<String> sections =
    geminiAnalysis!.split(RegExp(r'\n(?=\d\.\s)')).map((s) => s.trim()).toList();

    Color _getColor(String title) {
      if (title.toLowerCase().contains("insight")) return Colors.blue.shade50;
      if (title.toLowerCase().contains("recommend")) return Colors.green.shade50;
      if (title.toLowerCase().contains("risk")) return Colors.red.shade50;
      return Colors.grey.shade100;
    }

    IconData _getIcon(String title) {
      if (title.toLowerCase().contains("insight")) return Icons.science;
      if (title.toLowerCase().contains("recommend")) return Icons.medical_services;
      if (title.toLowerCase().contains("risk")) return Icons.warning_amber_rounded;
      return Icons.article;
    }

    return Column(
      children: sections.map((section) {
        List<String> lines = section.split("\n");
        String header = lines.first.trim();
        List<String> bullets = lines.sublist(1);

        return Card(
          color: _getColor(header),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getIcon(header), color: Colors.black54),
                    const SizedBox(width: 10),
                    Text(
                      header,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00247D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...bullets.map((b) {
                  if (b.trim().isEmpty) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            b.replaceAll("*", "").trim(),
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// ---- Chart Builder ----
  Widget _buildChart() {
    if (testData == null) return const SizedBox();

    final parameters = ["glucose_level", "bilirubin_level", "blood_level"];
    final values = parameters.map((p) {
      String val = testData![p]?.toString() ?? "0";
      return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), "")) ?? 0;
    }).toList();

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles:
              SideTitles(showTitles: true, reservedSize: 32, interval: 2),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  if (value.toInt() < parameters.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        parameters[value.toInt()]
                            .replaceAll("_level", "")
                            .toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    );
                  }
                  return const Text("");
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(parameters.length, (i) {
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: values[i],
                gradient: const LinearGradient(
                  colors: [Color(0xFF00247D), Color(0xFF007BFF)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 24,
                borderRadius: BorderRadius.circular(8),
              )
            ]);
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: const [
                  Icon(Icons.biotech, color: Color(0xFF00247D), size: 32),
                  SizedBox(width: 12),
                  Text(
                    "Lab Test Results",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00247D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Chart Section
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Parameter Overview",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00247D)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildChart(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // AI Insights
              const Text(
                "AI Insights",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00247D)),
              ),
              const SizedBox(height: 14),
              _buildInsights(),

              const SizedBox(height: 34),

              // Done Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00247D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 55),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
