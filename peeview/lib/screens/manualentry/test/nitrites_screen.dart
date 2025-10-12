import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peeview/screens/manualentry/test/urobilinogen_screen.dart';
import 'package:peeview/widgets/buttons/customize_manual_buttons.dart';
import 'package:peeview/widgets/navbar/customize_nav_auth.dart';

class NitritesScreen extends StatefulWidget {
  final String sessionId; // session ID to save data under the same test

  const NitritesScreen({super.key, required this.sessionId});

  @override
  State<NitritesScreen> createState() => _NitritesScreenState();
}

class _NitritesScreenState extends State<NitritesScreen> {
  String? selectedNitrite;

  final List<String> nitriteLevels = ["Negative", "Positive"];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveNitritesLevel() async {
    if (selectedNitrite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a nitrite level")),
      );
      return;
    }

    // Save to Firestore in the same urine_tests session
    await _firestore.collection("urine_tests").doc(widget.sessionId).set({
      "nitrites_level": selectedNitrite,
      "nitrites_level_timestamp": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UrobilinogenScreen(sessionId: widget.sessionId),
        ),
      );
    }
  }

  Widget _buildNitriteTiles() {
    return Column(
      children: nitriteLevels.map((level) {
        final isSelected = selectedNitrite == level;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedNitrite = level;
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
                      "Nitrates",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF063365),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Bacterial infection:",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 30),
                    _buildNitriteTiles(),
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
                    onNext: _saveNitritesLevel,
                    nextScreen: UrobilinogenScreen(sessionId: widget.sessionId),
                  ),
                  SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Step 10 of 15",
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
