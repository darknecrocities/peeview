import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'birthday_screen.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? _selectedGender;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Total steps in onboarding
  final int _totalSteps = 5;
  final int _currentStep = 1; // Adjust as needed

  Future<void> _saveGenderAndNext() async {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a gender")),
      );
      return;
    }

    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection("users").doc(uid).update({
        "gender": _selectedGender,
      });

      // Navigate to next onboarding screen
      print("Gender saved: $_selectedGender");
    } catch (e) {
      print("Error saving gender: $e");
    }
  }

  Widget _buildGenderOption(String gender, String assetPath) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Column(
        children: [
          CircleAvatar(
            radius: 90,
            backgroundImage: AssetImage(assetPath),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(height: 12),
          Text(
            gender,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
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
                          // Skip to next screen
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
                    "Which gender do you identify as?",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Gender options (stacked vertically)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGenderOption("Male", "lib/assets/images/male.png"),
                      const SizedBox(height: 30),
                      _buildGenderOption("Female", "lib/assets/images/female.png"),
                    ],
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
                onPressed: () async {
                  await _saveGenderAndNext(); // save gender first
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BirthdayScreen()), // go to BirthdayScreen
                  );
                },
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
