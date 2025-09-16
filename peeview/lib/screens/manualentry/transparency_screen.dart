import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gravity_screen.dart';

class TransparencyScreen extends StatefulWidget {
  final String sessionId; // Add sessionId

  const TransparencyScreen({super.key, required this.sessionId});

  @override
  State<TransparencyScreen> createState() => _TransparencyScreenState();
}

class _TransparencyScreenState extends State<TransparencyScreen> {
  String? selectedTransparency;

  final List<String> transparencies = [
    "Clear",
    "Slightly Hazy",
    "Hazy",
    "Cloudy",
    "Turbid",
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveTransparency() async {
    if (selectedTransparency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a transparency level")),
      );
      return;
    }

    // Save to the same session document
    await _firestore.collection("urine_tests").doc(widget.sessionId).update({
      "transparency": selectedTransparency,
      "transparency_timestamp": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transparency saved ✅")),
    );

    // Navigate to GravityScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GravityScreen(sessionId: widget.sessionId),
      ),
    );
  }

  Widget _buildTransparencyTiles() {
    return Column(
      children: transparencies.map((transparency) {
        final isSelected = selectedTransparency == transparency;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTransparency = transparency;
            });
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00247D) : Colors.white,
              border: Border.all(color: isSelected ? const Color(0xFF00247D) : Colors.grey),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              transparency,
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
                    "Transparency",
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
                      "How clear is the urine?",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildTransparencyTiles(),

                  const SizedBox(height: 256),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Skip: navigate to GravityScreen even if not selected
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GravityScreen(sessionId: widget.sessionId),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            minimumSize: const Size(double.infinity, 46),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text(
                            "Skip",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveTransparency, // Save & navigate to GravityScreen
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00247D),
                            minimumSize: const Size(double.infinity, 46),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text(
                            "Next",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.center,
                    child: Text("Step 2 of 15", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

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
