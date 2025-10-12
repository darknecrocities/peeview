import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peeview/widgets/navbar/customize_nav_auth.dart';
import 'package:peeview/widgets/buttons/customize_next_button.dart';
import 'package:peeview/widgets/cards/customize_progress_indicator.dart';
import 'blood_screen.dart';

class HeightScreen extends StatefulWidget {
  const HeightScreen({super.key});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  int _selectedFeet = 5; // Default feet
  int _selectedInches = 6; // Default inches
  int _selectedCm = 168; // Default cm
  String _selectedUnit = "Ft"; // Default unit: Ft or Cm

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Widget _buildHeightToggle({
    required String selectedUnit,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      width: 160,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFe6e6e6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: ["Ft", "Cm"].map((unit) {
          final isSelected = selectedUnit == unit;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(unit),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0XFF0062C8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  unit,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _saveHeightAndNext() async {
    try {
      final uid = _auth.currentUser!.uid;
      int heightValue = _selectedUnit == "Ft"
          ? (_selectedFeet * 12 + _selectedInches)
          : _selectedCm;
      await _firestore.collection("users").doc(uid).set({
        "height": heightValue,
        "heightUnit": _selectedUnit,
      }, SetOptions(merge: true));
      print("Height saved: $heightValue $_selectedUnit");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BloodScreen()),
      );
    } catch (e) {
      print("Error saving height: $e");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BloodScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomizeNavAuth(
        showBackButton: true,
        showSkipButton: true,
        nextScreen: BloodScreen(),
        showTitle: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 58),
                  const Text(
                    "What’s your Height?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: Center(
                      child: _selectedUnit == "Ft"
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Feet picker
                                SizedBox(
                                  width: 80,
                                  height: 200,
                                  child: CupertinoPicker(
                                    itemExtent: 40,
                                    scrollController:
                                        FixedExtentScrollController(
                                          initialItem: _selectedFeet - 3,
                                        ),
                                    onSelectedItemChanged: (int index) {
                                      setState(() {
                                        _selectedFeet = index + 3; // 3ft -> 8ft
                                      });
                                    },
                                    children: List<Widget>.generate(6, (index) {
                                      return Center(
                                        child: Text("${index + 3}"),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Ft",
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 20),
                                // Inches picker
                                SizedBox(
                                  width: 80,
                                  height: 200,
                                  child: CupertinoPicker(
                                    itemExtent: 40,
                                    scrollController:
                                        FixedExtentScrollController(
                                          initialItem: _selectedInches,
                                        ),
                                    onSelectedItemChanged: (int index) {
                                      setState(() {
                                        _selectedInches = index; // 0-11
                                      });
                                    },
                                    children: List<Widget>.generate(12, (
                                      index,
                                    ) {
                                      return Center(child: Text("$index"));
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "In",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            )
                          : SizedBox(
                              width: 100,
                              height: 200,
                              child: CupertinoPicker(
                                itemExtent: 40,
                                scrollController: FixedExtentScrollController(
                                  initialItem: _selectedCm - 100,
                                ),
                                onSelectedItemChanged: (int index) {
                                  setState(() {
                                    _selectedCm = index + 100; // 100cm -> 250cm
                                  });
                                },
                                children: List<Widget>.generate(151, (index) {
                                  return Center(child: Text("${index + 100}"));
                                }),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: _buildHeightToggle(
                      selectedUnit: _selectedUnit,
                      onChanged: (unit) {
                        setState(() {
                          _selectedUnit = unit;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomProgressIndicator(currentStep: 3),
                      CustomizeNextButton(
                        onPressed: () async {
                          _saveHeightAndNext();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
