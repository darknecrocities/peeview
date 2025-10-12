import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peeview/screens/signup/patient/weight_screen.dart';
import 'package:peeview/widgets/navbar/customize_nav_auth.dart';
import 'package:peeview/widgets/buttons/customize_next_button.dart';
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

  final int _totalSteps = 5;
  final int _currentStep = 1;

  Future<void> _saveGenderAndNext() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BirthdayScreen()),
    );
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection("users").doc(uid).update({
        "gender": _selectedGender,
      });
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
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
          ),
          const SizedBox(height: 12),
          Text(
            gender,
            style: TextStyle(
              fontSize: 18,
              color: isSelected ? Color(0XFF0062C8) : Colors.black,
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
        nextScreen: WeightScreen(),
        showTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween),
              const SizedBox(height: 58),
              const Text(
                "Which gender do you identify as?",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGenderOption("Male", "lib/assets/images/male.png"),
                  const SizedBox(height: 30),
                  _buildGenderOption("Female", "lib/assets/images/female.png"),
                ],
              ),
              const Spacer(),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressIndicator(),
                    CustomizeNextButton(
                      onPressed: () async {
                        await _saveGenderAndNext();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
