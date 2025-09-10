import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'weight_screen.dart'; // Import your next screen

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({super.key});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  DateTime _selectedDate = DateTime(2000, 1, 1);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int _totalSteps = 5;
  final int _currentStep = 2;

  // Save birthday to Firebase and navigate to WeightScreen
  Future<void> _saveBirthdayAndNext() async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection("users").doc(uid).set(
        {
          "birthdate": _selectedDate.toIso8601String(),
        },
        SetOptions(merge: true), // <-- ensures it will update or create
      );
      print("Birthday saved: $_selectedDate");

      // Navigate to WeightScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WeightScreen(),
        ),
      );
    } catch (e) {
      print("Error saving birthday: $e");
      // Optional: you can still show a SnackBar if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save birthday. Proceeding anyway..."),
        ),
      );

      // Navigate even if saving fails
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WeightScreen(),
        ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WeightScreen(),
                            ),
                          );
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
                    "What’s your Birthdate?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Expanded CupertinoDatePicker
                  Expanded(
                    child: Center(
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: _selectedDate,
                        minimumDate: DateTime(1900),
                        maximumDate: DateTime.now(),
                        onDateTimeChanged: (DateTime newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
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
                onPressed: _saveBirthdayAndNext,
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
