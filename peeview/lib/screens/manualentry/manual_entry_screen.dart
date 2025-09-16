import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'urine_color_screen.dart';

class ManualEntryScreen extends StatelessWidget {
  const ManualEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // center vertically
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              const Center(
                child: Text(
                  "Manual Entry",
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066E6),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle above checkboxes
              const Text(
                "Enter your urine test results step by step.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Fixed checkboxes (indented)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _checkItem("Complete urinalysis (15 tests)"),
                  const SizedBox(height: 12),
                  _checkItem("Takes about 5-10 minutes"),
                  const SizedBox(height: 12),
                  _checkItem("AI analysis when complete"),
                ],
              ),

              const SizedBox(height: 40),

              // Requirements
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(right: 150), // adjust value for left shift
                  child: Text(
                    "What you’ll need:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              const Align(
                alignment: Alignment.center,
                child: Text(
                  "• Lab report\n• A few minutes of your time",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 150),

              // Get Started button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066E6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    // Create a new test session in Firestore
                    final docRef = await _firestore.collection("urine_tests").add({
                      "startedAt": FieldValue.serverTimestamp(),
                      "completed": false,
                    });

                    final sessionId = docRef.id; // get the session ID

                    // Navigate to UrineColorScreen and pass sessionId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UrineColorScreen(sessionId: sessionId),
                      ),
                    );
                  },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                "Note: This app provides health guidance only and\ndoes not replace professional medical advice.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fixed checked checkbox widget
  static Widget _checkItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 33.0), // indent to the right
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_box,
            color: Color(0xFF33B5FF),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
