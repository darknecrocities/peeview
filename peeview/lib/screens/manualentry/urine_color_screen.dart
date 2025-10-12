import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peeview/widgets/customize_nav_auth.dart';
import 'transparency_screen.dart';
import 'package:peeview/widgets/customize_manual_buttons.dart';

class UrineColorScreen extends StatefulWidget {
  final String sessionId;
  const UrineColorScreen({super.key, required this.sessionId});

  @override
  State<UrineColorScreen> createState() => _UrineColorScreenState();
}

class _UrineColorScreenState extends State<UrineColorScreen> {
  String? selectedColor;

  final List<String> colors = [
    "Pale Yellow",
    "Yellow",
    "Dark Yellow",
    "Amber",
    "Orange",
    "Red",
    "Brown",
    "Colorless",
  ];

  Future<void> _saveColorAndNext() async {
    if (selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select a color to continue, or press Skip"),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("urine_tests")
        .doc(widget.sessionId)
        .update({
          "color": selectedColor,
          "color_timestamp": FieldValue.serverTimestamp(),
        });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransparencyScreen(sessionId: widget.sessionId),
      ),
    );
  }

  Widget _buildColorTiles() {
    return Column(
      children: colors.map((color) {
        final isSelected = selectedColor == color;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedColor = color;
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
              color,
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
      appBar: CustomizeNavAuth(
        showBackButton: true,
        showSkipButton: false,
        showTitle: false,
      ),
      backgroundColor: Colors.white,
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
                      "Urine Color",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF063365),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "What color is the urine sample?",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 30),
                    _buildColorTiles(),
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
                    onNext: _saveColorAndNext,
                    nextScreen: TransparencyScreen(sessionId: widget.sessionId),
                  ),

                  SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Step 1 of 15",
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
