import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../loading/welcome_screen.dart';

class BloodScreen extends StatefulWidget {
  const BloodScreen({super.key});

  @override
  State<BloodScreen> createState() => _BloodScreenState();
}

class _BloodScreenState extends State<BloodScreen> {
  String? _selectedBloodType; // A, B, AB, O
  String _selectedRh = '+'; // + or -
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _totalSteps = 5;
  final int _currentStep = 4;

  Future<void> _saveBloodAndNext() async {
    if (_selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a blood type.")),
      );
      return;
    }

    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection("users").doc(uid).set(
        {
          "bloodType": _selectedBloodType,
          "rhFactor": _selectedRh,
        },
        SetOptions(merge: true),
      );
      print("Blood Type saved: $_selectedBloodType $_selectedRh");

      // Navigate to WelcomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    } catch (e) {
      print("Error saving blood type: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Failed to save blood type. Proceeding anyway...")),
      );

      // Navigate to WelcomeScreen even if save fails
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
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
              padding:
              const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
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
                    "What’s your Blood Type?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

                  // Blood type toggle in rounded rectangle
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: ['A', 'B', 'AB', 'O'].map((type) {
                          bool selected = _selectedBloodType == type;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedBloodType = type;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                selected ? Colors.blue : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color:
                                  selected ? Colors.white : Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Big blood type indicator
                  Center(
                    child: Text(
                      _selectedBloodType != null
                          ? _selectedBloodType! + _selectedRh
                          : "-",
                      style: const TextStyle(
                        fontSize: 140,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // RH toggle
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Plus button
                        IconButton(
                          iconSize: 48,
                          icon: Icon(
                            Icons.add_circle,
                            color: _selectedRh == '+' ? Colors.blue : Colors.grey.shade400,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedRh = '+';
                            });
                          },
                        ),

                        // "or" text
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "or",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ),

                        // Minus button
                        IconButton(
                          iconSize: 48,
                          icon: Icon(
                            Icons.remove_circle,
                            color: _selectedRh == '-' ? Colors.blue : Colors.grey.shade400,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedRh = '-';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
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
                onPressed: _saveBloodAndNext,
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
