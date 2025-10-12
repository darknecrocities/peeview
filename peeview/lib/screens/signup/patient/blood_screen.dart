import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peeview/widgets/navbar/customize_nav_auth.dart';
import 'package:peeview/widgets/buttons/customize_next_button.dart';
import 'package:peeview/widgets/cards/customize_progress_indicator.dart';
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

  Future<void> _saveBloodAndNext() async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection("users").doc(uid).set({
        "bloodType": _selectedBloodType,
        "rhFactor": _selectedRh,
      }, SetOptions(merge: true));
      print("Blood Type saved: $_selectedBloodType $_selectedRh");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    } catch (e) {
      print("Error saving blood type: $e");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
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
        nextScreen: WelcomeScreen(),
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
                    "What’s your Blood Type?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Color(0XFF0062C8), width: 2),
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
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Color(0XFF0062C8)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Color(0XFF0062C8),
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
                  // Blood Type Indicator
                  Center(
                    child: Text(
                      _selectedBloodType != null
                          ? _selectedBloodType! + _selectedRh
                          : "",
                      style: const TextStyle(
                        fontSize: 140,
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF0062C8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                            color: _selectedRh == '+'
                                ? Color(0XFF0062C8)
                                : Color(0xFFe6e6e6),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedRh = '+';
                            });
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "or",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        // Minus button
                        IconButton(
                          iconSize: 48,
                          icon: Icon(
                            Icons.remove_circle,
                            color: _selectedRh == '-'
                                ? Color(0XFF0062C8)
                                : Color(0xFFe6e6e6),
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
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomProgressIndicator(currentStep: 4),
                      CustomizeNextButton(
                        onPressed: () async {
                          _saveBloodAndNext();
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
