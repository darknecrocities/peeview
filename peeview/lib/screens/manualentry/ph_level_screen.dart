import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'protein_screen.dart';
import 'package:peeview/widgets/customize_manual_buttons.dart';
import 'package:peeview/widgets/customize_nav_auth.dart';

class PHLevelScreen extends StatefulWidget {
  final String sessionId; // session ID to save data under the same test

  const PHLevelScreen({super.key, required this.sessionId});

  @override
  State<PHLevelScreen> createState() => _PHLevelScreenState();
}

class _PHLevelScreenState extends State<PHLevelScreen> {
  String? selectedPH;

  final List<String> phLevels = [
    "5.0",
    "6.0",
    "6.5",
    "7.0",
    "7.5",
    "8.0",
    "8.5",
    "9.0+",
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _savePHLevel() async {
    if (selectedPH == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a pH level")));
      return;
    }

    // Save to Firestore in the same urine_tests session
    await _firestore.collection("urine_tests").doc(widget.sessionId).update({
      "ph_level": selectedPH,
      "ph_level_timestamp": FieldValue.serverTimestamp(),
    });

    // Navigate to ProteinScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProteinScreen(sessionId: widget.sessionId),
      ),
    );
  }

  Widget _buildPHTiles() {
    return Column(
      children: phLevels.map((ph) {
        final isSelected = selectedPH == ph;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPH = ph;
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
              ph,
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
                      "pH Lvel",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF063365),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Acidity / alkalinity level:",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 30),
                    _buildPHTiles(),
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
                    onNext: _savePHLevel,
                    nextScreen: ProteinScreen(sessionId: widget.sessionId),
                  ),
                  SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Step 4 of 15",
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
