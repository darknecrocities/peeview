import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peeview/screens/manualentry/test/wb_screen.dart';
import 'package:peeview/widgets/buttons/customize_manual_buttons.dart';
import 'package:peeview/widgets/navbar/customize_nav_auth.dart';

class RedBloodCellsScreen extends StatefulWidget {
  final String sessionId;

  const RedBloodCellsScreen({super.key, required this.sessionId});

  @override
  State<RedBloodCellsScreen> createState() => _RedBloodCellsScreenState();
}

class _RedBloodCellsScreenState extends State<RedBloodCellsScreen> {
  String? selectedRBC;

  final List<String> rbcLevels = [
    "0-2/hpf",
    "3-5/hpf",
    "6-10/hpf",
    "11-25/hpf",
    ">25/hpf",
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveRBCLevel() async {
    if (selectedRBC == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an RBC level")),
      );
      return;
    }

    // ✅ Save to Firestore
    await _firestore.collection("urine_tests").doc(widget.sessionId).set({
      "rbc_level": selectedRBC,
      "rbc_level_timestamp": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // ✅ Navigate to BloodScreen
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WhiteBloodCellsScreen(sessionId: widget.sessionId),
        ),
      );
    }
  }

  Widget _buildRBCTiles() {
    return Column(
      children: rbcLevels.map((level) {
        final isSelected = selectedRBC == level;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedRBC = level;
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
                      "Red Blood Cells",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF063365),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Microscopic examination:",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 30),
                    _buildRBCTiles(),
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
                    onNext: _saveRBCLevel,
                    nextScreen: WhiteBloodCellsScreen(
                      sessionId: widget.sessionId,
                    ),
                  ),
                  SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Step 13 of 15",
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
