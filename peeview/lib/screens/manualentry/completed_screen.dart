import 'package:flutter/material.dart';
import 'package:peeview/screens/manualentry/results_screen.dart'; // ✅ Import ResultsScreen

class CompletedScreen extends StatelessWidget {
  final String sessionId;

  const CompletedScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Super white background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Center check image
              Expanded(
                child: Center(
                  child: Image.asset(
                    "lib/assets/images/complete_check.png",
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // ✅ Bottom text + button
              Column(
                children: [
                  const Text(
                    "Completed!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00247D), // Blue
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "All test parameters entered.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ Save & Analyze button → Go to ResultsScreen
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultsScreen(
                              sessionId: sessionId, // ✅ Pass sessionId
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00247D), // Blue
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        "Save and Analyze",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
