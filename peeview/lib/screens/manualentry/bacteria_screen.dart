import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peeview/screens/manualentry/completed_screen.dart';
import 'package:peeview/widgets/customize_manual_buttons.dart';
import 'package:peeview/widgets/customize_nav_auth.dart';

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

    await _firestore.collection("urine_tests").doc(widget.sessionId).set({
      "bacteria_level": selectedBacteria,
      "bacteria_level_timestamp": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompletedScreen(sessionId: widget.sessionId),
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
                      "Bacteria",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF063365),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Bacterial presence:",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 30),
                    _buildBacteriaTiles(),
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
                    onNext: _saveBacteriaLevel,
                    nextScreen: CompletedScreen(sessionId: widget.sessionId),
                  ),
                  SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Step 15 of 15",
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
