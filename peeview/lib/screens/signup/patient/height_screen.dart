import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final int _totalSteps = 5;
  final int _currentStep = 4; // Example step index

  Future<void> _saveHeightAndNext() async {
    try {
      final uid = _auth.currentUser!.uid;
      int heightValue = _selectedUnit == "Ft"
          ? (_selectedFeet * 12 + _selectedInches)
          : _selectedCm; // store as inches or cm

      await _firestore.collection("users").doc(uid).set(
        {
          "height": heightValue,
          "heightUnit": _selectedUnit,
        },
        SetOptions(merge: true),
      );

      print("Height saved: $heightValue $_selectedUnit");

      // Navigate to BloodScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BloodScreen()),
      );

    } catch (e) {
      print("Error saving height: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save height. Proceeding anyway...")),
      );
      // Navigate to BloodScreen even if saving fails
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BloodScreen()),
      );
    }
  }


  Widget _buildProgressIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_totalSteps, (index) {
        bool active = index < _currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.blue : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top row: Back and Skip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print("Skipped");
                        },
                        child: const Text(
                          "SKIP",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Question
                  const Text(
                    "What’s your Height?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Height picker
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
                              scrollController: FixedExtentScrollController(initialItem: _selectedFeet - 3),
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  _selectedFeet = index + 3; // 3ft -> 8ft
                                });
                              },
                              children: List<Widget>.generate(6, (index) {
                                return Center(child: Text("${index + 3}"));
                              }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text("Ft", style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 20),
                          // Inches picker
                          SizedBox(
                            width: 80,
                            height: 200,
                            child: CupertinoPicker(
                              itemExtent: 40,
                              scrollController: FixedExtentScrollController(initialItem: _selectedInches),
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  _selectedInches = index; // 0-11
                                });
                              },
                              children: List<Widget>.generate(12, (index) {
                                return Center(child: Text("$index"));
                              }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text("In", style: TextStyle(fontSize: 18)),
                        ],
                      )
                          : SizedBox(
                        width: 100,
                        height: 200,
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(initialItem: _selectedCm - 100),
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

                  const SizedBox(height: 20),

                  // Ft / Cm toggle
                  Center(
                    child: Container(
                      width: 160,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedUnit = "Ft";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedUnit == "Ft" ? Colors.blue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Ft",
                                  style: TextStyle(
                                    color: _selectedUnit == "Ft" ? Colors.white : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedUnit = "Cm";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedUnit == "Cm" ? Colors.blue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Cm",
                                  style: TextStyle(
                                    color: _selectedUnit == "Cm" ? Colors.white : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),

            // Bottom left: Progress indicators
            Positioned(
              bottom: 20,
              left: 18,
              child: _buildProgressIndicator(),
            ),

            // Bottom right: Next button
            Positioned(
              bottom: 20,
              right: 18,
              child: ElevatedButton(
                onPressed: _saveHeightAndNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
