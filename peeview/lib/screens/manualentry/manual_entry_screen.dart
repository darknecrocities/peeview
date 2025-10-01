import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../customize_appbar_screen.dart';
import 'package:peeview/widgets/customize_navbar.dart';
import 'urine_color_screen.dart';
import 'package:peeview/widgets/customize_back_button.dart'; // ✅ Import the back button

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomizeAppBarScreen(
        onNotificationsTap: () {
          debugPrint("Notifications tapped");
        },
        onProfileTap: () {
          debugPrint("Profile tapped");
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Custom Back Button
              const CustomizeBackButton(),

              const SizedBox(height: 12),

              // Header
              const Center(
                child: Text(
                  "Manual Entry",
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066E6),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle above checkboxes
              const Text(
                "Enter your urine test results step by step.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Fixed checkboxes
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _checkItem("Complete urinalysis (15 tests)"),
                  const SizedBox(height: 12),
                  _checkItem("Takes about 5-10 minutes"),
                  const SizedBox(height: 12),
                  _checkItem("AI analysis when complete"),
                ],
              ),

              const SizedBox(height: 40),

              // Requirements
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(right: 150),
                  child: Text(
                    "What you’ll need:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              const Align(
                alignment: Alignment.center,
                child: Text(
                  "• Lab report\n• A few minutes of your time",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Get Started button
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
                        const SnackBar(
                          content: Text("No logged in user found."),
                        ),
                      );
                      return;
                    }

                    // 🔹 Fetch user profile from `users` collection
                    final userDoc = await _firestore
                        .collection("users")
                        .doc(currentUser.uid)
                        .get();

                    String userName = "User";
                    if (userDoc.exists) {
                      final data = userDoc.data() as Map<String, dynamic>;
                      userName = data["name"] ?? "User";
                    }

                    // 🔹 Create a new test session with userId and name
                    final docRef =
                    await _firestore.collection("urine_tests").add({
                      "startedAt": FieldValue.serverTimestamp(),
                      "completed": false,
                      "userId": currentUser.uid,
                      "userName": userName,
                    });

                    final sessionId = docRef.id;

                    // Navigate to UrineColorScreen
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                "Note: This app provides health guidance only and\ndoes not replace professional medical advice.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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

  // Fixed checked checkbox widget
  static Widget _checkItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 33.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_box,
            color: Color(0xFF33B5FF),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
