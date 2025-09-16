import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bilirubin_screen.dart';

class GlucoseScreen extends StatefulWidget {
  final String sessionId; // session ID to save data under the same test

  const GlucoseScreen({super.key, required this.sessionId});

  @override
  State<GlucoseScreen> createState() => _GlucoseScreenState();
}

class _GlucoseScreenState extends State<GlucoseScreen> {
  String? selectedGlucose;

  final List<String> glucoseLevels = [
    "Negative",
    "Trace",
    "+1",
    "+2",
    "+3",
    "+4",
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveGlucoseLevel() async {
    if (selectedGlucose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a glucose level")),
      );
      return;
    }

    // Save to Firestore in the same urine_tests session
    await _firestore.collection("urine_tests").doc(widget.sessionId).update({
      "glucose_level": selectedGlucose,
      "glucose_level_timestamp": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Glucose Level saved ✅")),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BilirubinScreen(sessionId: widget.sessionId),
      ),
    );
    // Navigate to next screen if needed
    // Example: Navigator.push(...);
  }

  Widget _buildGlucoseTiles() {
    return Column(
      children: glucoseLevels.map((glucose) {
        final isSelected = selectedGlucose == glucose;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedGlucose = glucose;
            });
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00247D) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF00247D) : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              glucose,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Glucose Level",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sugar content in urine:",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Glucose selection tiles
                  _buildGlucoseTiles(),

                  const SizedBox(height: 116),

                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Skip
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            minimumSize: const Size(double.infinity, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveGlucoseLevel, // Save & proceed
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00247D),
                            minimumSize: const Size(double.infinity, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            "Next",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.center,
                    child: Text("Step 6 of 15", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Back button
            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
