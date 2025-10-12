import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'glucose_screen.dart';
import 'package:peeview/widgets/buttons/customize_manual_buttons.dart';
import 'package:peeview/widgets/navbar/customize_nav_auth.dart';

class ProteinScreen extends StatefulWidget {
  final String sessionId; // session ID to save data under the same test

  const ProteinScreen({super.key, required this.sessionId});

  @override
  State<ProteinScreen> createState() => _ProteinScreenState();
}

class _ProteinScreenState extends State<ProteinScreen> {
  String? selectedProtein;

  final List<String> proteinLevels = [
    "Negative",
    "Trace",
    "+1",
    "+2",
    "+3",
    "+4",
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveProteinLevel() async {
    if (selectedProtein == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a protein level")),
      );
      return;
    }

    // Save to Firestore in the same urine_tests session
    await _firestore.collection("urine_tests").doc(widget.sessionId).update({
      "protein_level": selectedProtein,
      "protein_level_timestamp": FieldValue.serverTimestamp(),
    });

    // Navigate to GlucoseScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GlucoseScreen(sessionId: widget.sessionId),
      ),
    );
  }

  Widget _buildProteinTiles() {
    return Column(
      children: proteinLevels.map((protein) {
        final isSelected = selectedProtein == protein;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedProtein = protein;
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
              protein,
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
                      "pH Level",
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
                    _buildProteinTiles(),
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
                      _saveProteinLevel();
                    },
                    nextScreen: GlucoseScreen(sessionId: widget.sessionId),
                  ),

                  SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Step 5 of 15",
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
