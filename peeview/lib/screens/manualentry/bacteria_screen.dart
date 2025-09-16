import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peeview/screens/manualentry/completed_screen.dart'; // ✅ or next screen after Bacteria

class BacteriaScreen extends StatefulWidget {
  final String sessionId;

  const BacteriaScreen({super.key, required this.sessionId});

  @override
  State<BacteriaScreen> createState() => _BacteriaScreenState();
}

class _BacteriaScreenState extends State<BacteriaScreen> {
  String? selectedBacteria;

  final List<String> bacteriaLevels = [
    "Few",
    "Moderate",
    "Many",
    "26-50/hpf",
    ">50/hpf",
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveBacteriaLevel() async {
    if (selectedBacteria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a bacteria level")),
      );
      return;
    }

    // ✅ Save to Firestore
    await _firestore.collection("urine_tests").doc(widget.sessionId).set({
      "bacteria_level": selectedBacteria,
      "bacteria_level_timestamp": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bacteria level saved ✅")),
    );

    // ✅ Navigate to next screen (example: WBC Screen)
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CompletedScreen(sessionId: widget.sessionId),
        ),
      );
    }
  }

  Widget _buildBacteriaTiles() {
    return Column(
      children: bacteriaLevels.map((level) {
        final isSelected = selectedBacteria == level;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedBacteria = level;
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
              level,
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
                    "Bacteria",
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
                      "Bacterial presence:",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bacteria selection tiles
                  _buildBacteriaTiles(),

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
                          onPressed: _saveBacteriaLevel, // ✅ Save & go next
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
                    child: Text("Step 15 of 15",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.grey),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
