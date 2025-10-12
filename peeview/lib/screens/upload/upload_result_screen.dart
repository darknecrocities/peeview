import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:peeview/screens/scan/scan_result.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';

class UploadResultScreen extends StatefulWidget {
  final File file;
  const UploadResultScreen({super.key, required this.file});

  @override
  State<UploadResultScreen> createState() => _UploadResultScreenState();
}

class _UploadResultScreenState extends State<UploadResultScreen> {
  bool _processing = true;
  Map<String, dynamic> _results = {};

  @override
  void initState() {
    super.initState();

    // Hide system UI (full screen)
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    _processFile();
  }

  @override
  void dispose() {
    // Restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }



  Future<void> _processFile() async {
    setState(() => _processing = true);

    try {
      final inputImage = InputImage.fromFile(widget.file);
      final textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      final extractedText = recognizedText.text.trim();
      await textRecognizer.close();

      if (extractedText.isEmpty) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No text detected in the file.")),
        );
        return;
      }

      const apiKey = "AIzaSyCYpADok1bJHn6dy5RHPcb_HaPL1ld3mmM";
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
      );

      final prompt = """
You are an AI medical assistant analyzing lab results.

Below is the OCR text from a patient's urine test:

\"\"\"$extractedText\"\"\"

Tasks:
1. Estimate the likelihood (0–100%) that the patient has Chronic Kidney Disease (CKD).
2. Provide an approximately 80-word medical interpretation of the urinalysis findings.
3. End your response with this exact format:
CKD Probability: [number]%

Keep your response plain text. Do not use JSON, bullet points, or markdown.
""";

      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String aiText = "";
        try {
          aiText = data["candidates"][0]["content"]["parts"][0]["text"] ?? "";
        } catch (_) {
          aiText = "No insights generated. Please retry with a clearer image.";
        }

        final regex = RegExp(r'CKD Probability:\s*(\d+)%');
        int ckdProbability = 0;
        final match = regex.firstMatch(aiText);
        if (match != null) {
          ckdProbability = int.tryParse(match.group(1) ?? "0") ?? 0;
        }

        int nonCkdProbability = (100 - ckdProbability).clamp(0, 100);
        String status;
        if (ckdProbability >= 70) {
          status = "HIGH";
        } else if (ckdProbability >= 40) {
          status = "MODERATE";
        } else {
          status = "LOW";
        }

        if (!mounted) return;

        // Save results and stop processing
        setState(() {
          _results = {
            "aiInsights": aiText,
            "suggestedAction":
            "Consult a healthcare professional for further advice.",
            "diseasePrediction": {
              "ckdProbability": ckdProbability,
              "nonCkdProbability": nonCkdProbability,
            },
            "status": status,
          };
          _processing = false;
        });
      } else {
        debugPrint("Gemini API HTTP ${response.statusCode}: ${response.body}");
        if (mounted) {
          setState(() => _processing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Text('Gemini API error (${response.statusCode}). Try again.'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Gemini/network error: $e');
      if (mounted) setState(() => _processing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to communicate with AI service: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _processing
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text("Processing your lab report...")
          ],
        )
            : _results.isNotEmpty
            ? Column(
          children: [
            Expanded(
              child: ScanResultScreen(
                results: _results,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity, // full-width button
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // green color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0), // taller button
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Go back to dashboard
                  },
                  child: const Text("Done"),
                ),
              ),
            ),
          ],
        )
            : const Text("Processing failed."),
      ),
    );
  }

}
