import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:peeview/screens/dashboard_screen.dart';
import 'package:peeview/widgets/customize_bottom_navbar.dart';
import 'prediction_card.dart';
import 'tracked_results.dart';
import 'package:http/http.dart' as http;

class ResultsScreen extends StatefulWidget {
  final String? sessionId;
  const ResultsScreen({super.key, this.sessionId});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  String? geminiAnalysis;
  Map<String, dynamic>? testData;
  String status = "HEALTHY";
  int _selectedIndex = 0;
  String userName = "User";
  String testDate = "";
  String testTime = "";

  double _ckdProbability = 0.0;
  double _nonCkdProbability = 0.0;

  // ✅ Initialize Gemini model
  final String _geminiApiKey = "AIzaSyCYpADok1bJHn6dy5RHPcb_HaPL1ld3mmM";
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: "gemini-pro", apiKey: _geminiApiKey);
    _fetchAndAnalyze();
  }

  // ---------------- Parsing Helpers ---------------- //
  double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      final s = value.trim();
      final cleaned = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
      final d = double.tryParse(cleaned);
      if (d != null) return d;
      if (s.endsWith('%')) {
        final n = double.tryParse(s.replaceAll('%', '').trim());
        if (n != null) return (n / 100.0);
      }
      return defaultValue;
    }
    return defaultValue;
  }

  int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final match = RegExp(r'(\d+)').firstMatch(value.trim());
      if (match != null) return int.tryParse(match.group(0)!) ?? defaultValue;
    }
    return defaultValue;
  }

  // ---------------- AI Helper ---------------- //
  Future<String> _callGeminiAnalysisREST(
    Map<String, dynamic> safeData,
    String status,
  ) async {
    try {
      final apiKey = _geminiApiKey; // already declared
      final url =
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey";

      final prompt =
          """
You are a helpful medical assistant. Analyze this urine test result and provide a clear conclusion.

Guidelines:
- Write a short summary (50–80 words).
- Use simple, non-alarming, patient-friendly language.
- Summarize the overall findings (normal, monitor, or consult a doctor).
- Avoid listing raw values (like WBC=...).
- Focus on what the results may mean for the patient.

Test Data: ${jsonEncode(_sanitizeData(safeData))}
Status: $status
""";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
        if (text != null && text.toString().trim().isNotEmpty) {
          return text.toString().trim();
        }
        return "No analysis text returned.";
      } else {
        debugPrint("Gemini API error: ${response.body}");
        return "Analysis failed. Error ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("Error calling Gemini REST: $e");
      return "Analysis could not be generated due to a system error.";
    }
  }

  /// 🔄 Helper to clean Firestore Timestamps into strings
  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is Timestamp) {
        result[key] = value.toDate().toIso8601String();
      } else if (value is Map) {
        result[key] = _sanitizeData(Map<String, dynamic>.from(value));
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  // ---------------- Fetch & Analyze ---------------- //
  Future<void> _fetchAndAnalyze() async {
    try {
      DocumentSnapshot<Map<String, dynamic>>? doc;

      if (widget.sessionId != null) {
        doc = await _firestore
            .collection("urine_tests")
            .doc(widget.sessionId)
            .get();
      } else {
        final snapshot = await _firestore
            .collection("urine_tests")
            .orderBy("startedAt", descending: true)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          doc = snapshot.docs.first;
        }
      }

      if (doc == null || !doc.exists) {
        setState(() {
          isLoading = false;
          geminiAnalysis = "No test data found.";
        });
        return;
      }

      testData = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);

      // ---------------- Date Formatting ---------------- //
      DateTime? dateForDisplay;
      if (testData?["createdAt"] is Timestamp) {
        dateForDisplay = (testData!["createdAt"] as Timestamp).toDate();
      } else if (testData?["startedAt"] is Timestamp) {
        dateForDisplay = (testData!["startedAt"] as Timestamp).toDate();
      }
      if (dateForDisplay != null) {
        testDate = DateFormat("MMMM d, y").format(dateForDisplay);
        testTime = DateFormat("hh:mm a").format(dateForDisplay);
      }

      // ---------------- User Name ---------------- //
      if (testData?["userName"] != null) {
        userName = (testData?["userName"] ?? "").toString();
      } else {
        final userId = testData?["userId"];
        if (userId != null) {
          final userDoc = await _firestore
              .collection("users")
              .doc(userId)
              .get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            userName = (userData["name"] ?? userName).toString();
          }
        }
      }

      // ---------------- Status Logic ---------------- //
      final glucoseStr = (testData?["glucose_level"] ?? "")
          .toString()
          .toUpperCase();

      if (["+3", "+4"].contains(glucoseStr)) {
        status = "DANGER";
      } else if (["TRACE", "+1", "+2"].contains(glucoseStr)) {
        status = "WARNING";
      } else {
        status = "HEALTHY";
      }

      // ---------------- CKD Probability ---------------- //
      final storedCkd = _parseDouble(testData?['ckdProbability']);
      final storedNon = _parseDouble(testData?['nonCkdProbability']);
      if (storedCkd > 0 || storedNon > 0) {
        final total = storedCkd + storedNon;
        if (total > 0) {
          _ckdProbability = (storedCkd / total);
          _nonCkdProbability = (storedNon / total);
        }
      } else {
        final protein = _parseDouble(testData?['protein_level']);
        final wbc = _parseDouble(testData?['wbc_level']);
        final bacteria = _parseDouble(testData?['bacteria_level']);
        double score = 0.0;
        score += (protein > 0 ? (protein / 4.0) * 0.5 : 0.0);
        score += (wbc > 0 ? (wbc / 50.0) * 0.3 : 0.0);
        score += (bacteria > 0 ? (bacteria / 50.0) * 0.2 : 0.0);
        score = score.clamp(0.0, 1.0);
        _ckdProbability = score;
        _nonCkdProbability = (1.0 - score).clamp(0.0, 1.0);
      }

      // ---------------- Gemini AI ---------------- //
      final geminiValue = testData?["geminiAnalysis"];
      if (geminiValue != null &&
          geminiValue is String &&
          geminiValue.trim().isNotEmpty &&
          !geminiValue.startsWith("Error")) {
        geminiAnalysis = geminiValue;
      } else {
        geminiAnalysis = await _callGeminiAnalysisREST(testData!, status);
      }

      setState(() => isLoading = false);
    } catch (e, st) {
      print("Fetch/Analyze error: $e\n$st");
      setState(() {
        geminiAnalysis = "Error: $e";
        isLoading = false;
      });
    }
  }

  // ---------------- Save Results ---------------- //
  Future<void> _saveResults() async {
    if (testData == null) return;
    try {
      await _firestore.collection("urine_tests").doc(widget.sessionId).update({
        "status": status,
        "geminiAnalysis": geminiAnalysis,
        "analyzedAt": Timestamp.now(),
        "ckdProbability": _ckdProbability,
        "nonCkdProbability": _nonCkdProbability,
        "completed": true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Results saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save results: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------- UI ---------------- //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        toolbarHeight: 80,
        title: const Text(
          "Lab Test Results",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0XFF0062C8),
            fontFamily: 'DM Sans',
            fontSize: 28,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(
                            text: "Hello,\n",
                            style: TextStyle(fontSize: 20),
                          ),
                          TextSpan(
                            text: "$userName !",
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'DM Sans',
                              color: Color(0XFF0062C8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      "Take a look at your results.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(height: 30),
                    // AI Insights
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.25),
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
                            "AI Insights",
                            style: TextStyle(
                              color: Color(0XFF0062C8),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            geminiAnalysis ?? "",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    PredictionCard(
                      ckdProbability: _ckdProbability,
                      nonCkdProbability: _nonCkdProbability,
                      wbc: _parseInt(testData?['wbc_level']),
                      bacteria: _parseInt(testData?['bacteria_level']),
                      transparency: _parseInt(testData?['transparency']),
                      protein: _parseInt(testData?['protein_level']),
                    ),
                    const SizedBox(height: 26),
                    TrackedResultsCard(
                      values: {
                        'wbc_level': testData?['wbc_level'],
                        'rbc_level': testData?['rbc_level'],
                        'bacteria_level': testData?['bacteria_level'],
                        'transparency': testData?['transparency'],
                        'protein_level': testData?['protein_level'],
                        'glucose_level': testData?['glucose_level'],
                        'bilirubin_level': testData?['bilirubin_level'],
                        'blood_level': testData?['blood_level'],
                        'leukocytes_level': testData?['leukocytes_level'],
                        'nitrites_level': testData?['nitrites_level'],
                        'urobilinogen_level': testData?['urobilinogen_level'],
                        'ketones_level': testData?['ketones_level'],
                        'color': testData?['color'],
                        'specific_gravity': testData?['specific_gravity'],
                        'ph_level': testData?['ph_level'],
                      },
                    ),

                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          backgroundColor: Color(0XFF0062C8),
                        ),
                        onPressed: _saveResults,
                        child: const Text(
                          "Done",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 20,
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
