import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peeview/screens/manualentry/nitrites_screen.dart';
import 'package:peeview/widgets/customize_manual_buttons.dart';
import 'package:peeview/widgets/customize_nav_auth.dart';

class LeukocytesScreen extends StatefulWidget {
  final String sessionId;

  const LeukocytesScreen({super.key, required this.sessionId});

  @override
  State<LeukocytesScreen> createState() => _LeukocytesScreenState();
}

class _LeukocytesScreenState extends State<LeukocytesScreen> {
  String? selectedLeukocytes;

  final List<String> leukocyteLevels = [
    "Negative",
    "Trace",
    "+1",
    "+2",
    "+3",
    "Large",
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveLeukocytesLevel() async {
    if (selectedLeukocytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a leukocyte level")),
      );
      return;
    }

    await _firestore.collection("urine_tests").doc(widget.sessionId).set({
      "leukocytes_level": selectedLeukocytes,
      "leukocytes_level_timestamp": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NitritesScreen(sessionId: widget.sessionId),
        ),
      );
    }
  }

  Widget _buildLeukocyteTiles() {
    return Column(
      children: leukocyteLevels.map((level) {
        final isSelected = selectedLeukocytes == level;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedLeukocytes = level;
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
                      "Leukocytes",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF063365),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "White blood cells:",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 30),
                    _buildLeukocyteTiles(),
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
                    onNext: _saveLeukocytesLevel,
                    nextScreen: NitritesScreen(sessionId: widget.sessionId),
                  ),
                  SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Step 9 of 15",
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
