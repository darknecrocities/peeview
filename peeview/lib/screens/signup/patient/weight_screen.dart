import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peeview/widgets/navbar/customize_nav_auth.dart';
import 'package:peeview/widgets/buttons/customize_next_button.dart';
import 'height_screen.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

Widget _buildWeightToggle({
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
      children: ["Kg", "Lbs"].map((unit) {
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

class _WeightScreenState extends State<WeightScreen> {
  int _selectedWeight = 66;
  String _selectedUnit = "Kg";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int _totalSteps = 5;

  Future<void> _saveWeightAndNext() async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection("users").doc(uid).set({
        "weight": _selectedWeight,
        "weightUnit": _selectedUnit,
      }, SetOptions(merge: true));
      print("Weight saved: $_selectedWeight $_selectedUnit");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HeightScreen()),
      );
    } catch (e) {
      print("Error saving weight: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save weight. Proceeding anyway..."),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HeightScreen()),
      );
    }
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_totalSteps, (index) {
        bool active = index == 2;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Color(0XFF0062C8) : Color(0xFFe6e6e6),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomizeNavAuth(
        showBackButton: true,
        showSkipButton: true,
        nextScreen: HeightScreen(),
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
                    "What’s your Weight?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        height: 200,
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(
                            initialItem: _selectedWeight - 30,
                          ),
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              _selectedWeight = index + 30;
                            });
                          },
                          children: List<Widget>.generate(171, (index) {
                            return Center(
                              child: Text(
                                "${index + 30}",
                                style: const TextStyle(fontSize: 22),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: _buildWeightToggle(
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
                      _buildProgressIndicator(),
                      CustomizeNextButton(
                        onPressed: () async {
                          _saveWeightAndNext();
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
