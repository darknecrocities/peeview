import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peeview/screens/manualentry/test/ketones_screen.dart';
import 'package:peeview/widgets/buttons/customize_manual_buttons.dart';
import 'package:peeview/widgets/navbar/customize_nav_auth.dart';

class UrobilinogenScreen extends StatefulWidget {
  final String sessionId;

  const UrobilinogenScreen({super.key, required this.sessionId});

  @override
  State<UrobilinogenScreen> createState() => _UrobilinogenScreenState();
}

class _UrobilinogenScreenState extends State<UrobilinogenScreen> {
  String? selectedUrobilinogen;

  final List<String> urobilinogenLevels = [
    "Normal",
    "2 mg/dL",
    "4 mg/dL",
    "8 mg/dL",
    "12+ mg/dL",
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveUrobilinogenLevel() async {
    if (selectedUrobilinogen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a Urobilinogen level")),
      );
      return;
    }

    await _firestore.collection("urine_tests").doc(widget.sessionId).set({
      "urobilinogen_level": selectedUrobilinogen,
      "urobilinogen_level_timestamp": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KetonesScreen(sessionId: widget.sessionId),
        ),
      );
    }
  }

  Widget _buildUrobilinogenTiles() {
    return Column(
      children: urobilinogenLevels.map((level) {
        final isSelected = selectedUrobilinogen == level;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedUrobilinogen = level;
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
                      "Urobilinogen",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF063365),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Liver function:",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 30),
                    _buildUrobilinogenTiles(),
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
                    onNext: _saveUrobilinogenLevel,
                    nextScreen: KetonesScreen(sessionId: widget.sessionId),
                  ),
                  SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Step 11 of 15",
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
