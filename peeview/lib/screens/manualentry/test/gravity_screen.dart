import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ph_level_screen.dart';
import 'package:peeview/widgets/buttons/customize_manual_buttons.dart';
import 'package:peeview/widgets/navbar/customize_nav_auth.dart';

class GravityScreen extends StatefulWidget {
  final String sessionId; // session ID to save data under the same test

  const GravityScreen({super.key, required this.sessionId});

  @override
  State<GravityScreen> createState() => _GravityScreenState();
}

class _GravityScreenState extends State<GravityScreen> {
  String? selectedGravity;

  final List<String> gravityLevels = [
    "1.000",
    "1.005",
    "1.010",
    "1.015",
    "1.020",
    "1.025",
    "1.030+",
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveGravity() async {
    if (selectedGravity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a gravity level")),
      );
      return;
    }

    // Save to Firestore in the same urine_tests session
    await _firestore.collection("urine_tests").doc(widget.sessionId).update({
      "specific_gravity": selectedGravity,
      "specific_gravity_timestamp": FieldValue.serverTimestamp(),
    });

    // Navigate to PHLevelScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PHLevelScreen(sessionId: widget.sessionId),
      ),
    );
  }

  Widget _buildGravityTiles() {
    return Column(
      children: gravityLevels.map((gravity) {
        final isSelected = selectedGravity == gravity;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedGravity = gravity;
            });
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0XFF0062C8) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0XFF063365) : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              gravity,
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
      appBar: CustomizeNavAuth(
        showBackButton: true,
        showSkipButton: false,
        showTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Gravity",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF063365),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Urine concentration level:",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 30),
                    _buildGravityTiles(),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomizeManualButtons(
                    onNext: _saveGravity,
                    nextScreen: PHLevelScreen(sessionId: widget.sessionId),
                  ),
                  SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Step 3 of 15",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }
}
