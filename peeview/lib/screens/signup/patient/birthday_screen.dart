import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peeview/widgets/navbar/customize_nav_auth.dart';
import 'package:peeview/widgets/buttons/customize_next_button.dart';
import 'weight_screen.dart';

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

  Future<void> _saveBirthdayAndNext() async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection("users").doc(uid).set({
        "birthdate": _selectedDate.toIso8601String(),
      }, SetOptions(merge: true));
      print("Birthday saved: $_selectedDate");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WeightScreen()),
      );
    } catch (e) {
      print("Error saving birthday: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save birthday. Proceeding anyway..."),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WeightScreen()),
      );
    }
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_totalSteps, (index) {
        bool active = index == 1;
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
        nextScreen: BirthdayScreen(),
        showTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 58),
              const Text(
                "When's your Birthdate?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProgressIndicator(),
                  CustomizeNextButton(
                    onPressed: () async {
                      _saveBirthdayAndNext();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}
