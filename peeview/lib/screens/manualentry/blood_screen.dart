import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'leukocytes_screen.dart'; // ✅ import your leukocytes screen

class BloodScreen extends StatefulWidget {
  final String sessionId; // session ID to save data under the same test

  const BloodScreen({super.key, required this.sessionId});

  @override
  State<BloodScreen> createState() => _BloodScreenState();
}

class _BloodScreenState extends State<BloodScreen> {
  String? selectedBlood;

  final List<String> bloodLevels = [
    "Negative",
    "Trace",
    "+1",
    "+2",
    "+3",
    "Large",
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveBloodLevel() async {
    if (selectedBlood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a blood (erythrocytes) level")),
      );
      return;
    }

    // Save to Firestore in the same urine_tests session
    await _firestore.collection("urine_tests").doc(widget.sessionId).update({
      "blood_level": selectedBlood,
      "blood_level_timestamp": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Blood (Erythrocytes) Level saved ✅")),
    );

    // ✅ Navigate to LeukocytesScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeukocytesScreen(sessionId: widget.sessionId),
      ),
    );
  }

  Widget _buildBloodTiles() {
    return Column(
      children: bloodLevels.map((blood) {
        final isSelected = selectedBlood == blood;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedBlood = blood;
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
              blood,
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
                    "Blood (Erythrocytes)",
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
                      "Red blood cells in urine:",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Blood selection tiles
                  _buildBloodTiles(),

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
                          onPressed: _saveBloodLevel, // Save & go to Leukocytes
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
                    child: Text("Step 8 of 15", style: TextStyle(fontSize: 12, color: Colors.grey)),
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
