import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peeview/widgets/navbar/customize_bottom_navbar.dart';
import 'test/urine_color_screen.dart';
import 'package:peeview/widgets/buttons/customize_back_button.dart';
import 'package:peeview/widgets/appbar/customize_app_bar_dash.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _selectedIndex = 0;

  static Widget _checkItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_box, color: Color(0XFF0062C8), size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomizeAppBarDash(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    CustomizeBackButton(),
                    const SizedBox(height: 60),
                    const Center(
                      child: Text(
                        "Manual Entry",
                        style: TextStyle(
                          color: Color(0XFF0062C8),
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Enter your urine test results step by step.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _checkItem("Complete urinalysis (15 tests)"),
                        _checkItem("Takes about 5-10 minutes"),
                        _checkItem("AI analysis when complete"),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "What you’ll need:\n",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "• Lab report\n• A few minutes of your time",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066E6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  final currentUser = _auth.currentUser;

                  if (currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No logged in user found.")),
                    );
                    return;
                  }
                  final userDoc = await _firestore
                      .collection("users")
                      .doc(currentUser.uid)
                      .get();

                  String userName = "User";
                  if (userDoc.exists) {
                    final data = userDoc.data() as Map<String, dynamic>;
                    userName = data["name"] ?? "User";
                  }
                  final docRef = await _firestore
                      .collection("urine_tests")
                      .add({
                        "startedAt": FieldValue.serverTimestamp(),
                        "completed": false,
                        "userId": currentUser.uid,
                        "userName": userName,
                      });
                  final sessionId = docRef.id;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UrineColorScreen(sessionId: sessionId),
                    ),
                  );
                },
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Note: This app provides health guidance only and does not replace professional medical advice.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          debugPrint("Selected Nav Index: $_selectedIndex");
        },
      ),
    );
  }
}
