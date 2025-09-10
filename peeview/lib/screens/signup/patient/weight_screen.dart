import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'height_screen.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  int _selectedWeight = 66; // Default weight
  String _selectedUnit = "Kg"; // Default unit

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int _totalSteps = 5;
  final int _currentStep = 3; // Example step index
  // Make sure the file path is correct

  Future<void> _saveWeightAndNext() async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection("users").doc(uid).set(
        {
          "weight": _selectedWeight,
          "weightUnit": _selectedUnit,
        },
        SetOptions(merge: true),
      );
      print("Weight saved: $_selectedWeight $_selectedUnit");

      // Navigate to HeightScreen after saving
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HeightScreen()),
      );
    } catch (e) {
      print("Error saving weight: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save weight. Proceeding anyway...")),
      );
      // Navigate to HeightScreen even if saving fails
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
                    "What’s your Weight?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Wheel picker for weight
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        height: 200,
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(initialItem: _selectedWeight - 30),
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              _selectedWeight = index + 30; // 30kg -> 200kg
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

                  // Kg / Lbs toggle switch
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
                          // Kg option
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedUnit = "Kg";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedUnit == "Kg" ? Colors.blue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Kg",
                                  style: TextStyle(
                                    color: _selectedUnit == "Kg" ? Colors.white : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Lbs option
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedUnit = "Lbs";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedUnit == "Lbs" ? Colors.blue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Lbs",
                                  style: TextStyle(
                                    color: _selectedUnit == "Lbs" ? Colors.white : Colors.black54,
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
                onPressed: _saveWeightAndNext,
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
