import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'leukocytes_screen.dart';
import 'package:peeview/widgets/buttons/customize_manual_buttons.dart';
import 'package:peeview/widgets/navbar/customize_nav_auth.dart';

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
        const SnackBar(
          content: Text("Please select a blood (erythrocytes) level"),
        ),
      );
      return;
    }

    await _firestore.collection("urine_tests").doc(widget.sessionId).update({
      "blood_level": selectedBlood,
      "blood_level_timestamp": FieldValue.serverTimestamp(),
    });

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
                      "Blood (Erythrocytes)",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF063365),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Red blood cells in urine:",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 30),
                    _buildBloodTiles(),
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
                    onNext: () {
                      _saveBloodLevel();
                    },
                    nextScreen: LeukocytesScreen(sessionId: widget.sessionId),
                  ),
                  SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Step 8 of 15",
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
