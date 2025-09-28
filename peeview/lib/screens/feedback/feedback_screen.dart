import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../customize_appbar_screen.dart';
import '../dashboard_screen.dart'; // ✅ import your dashboard

class FeedbackScreen extends StatefulWidget {
  final String? category;

  const FeedbackScreen({super.key, this.category});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int selectedMood = 3; // default: happy
  String? feedbackType; // dropdown value
  final TextEditingController _controller = TextEditingController();
  bool isIssue = false;

  @override
  void initState() {
    super.initState();

    // ✅ Hide system UI (immersive mode)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _controller.dispose();

    // ✅ Restore UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection("feedbacks").add({
      "userId": user?.uid,
      "category": widget.category ?? "General",
      "mood": selectedMood,
      "feedbackType": feedbackType ?? "Other feedback",
      "text": _controller.text,
      "isIssue": isIssue,
      "timestamp": FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback submitted!")),
    );

    // ✅ Navigate to DashboardScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false, // clear history so user can't go back
    );
  }

  Widget _buildMoodIcon(int index, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => setState(() => selectedMood = index),
      child: CircleAvatar(
        radius: 24,
        backgroundColor:
        selectedMood == index ? color.withOpacity(0.2) : Colors.grey[200],
        child: Icon(
          icon,
          color: selectedMood == index ? color : Colors.grey,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ✅ Custom AppBar
          CustomizeAppBarScreen(
            onNotificationsTap: () {
              Navigator.pushNamed(context, "/notifications");
            },
            onProfileTap: () {
              Navigator.pushNamed(context, "/profile");
            },
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button + Title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "Feedback",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Image
                  Image.asset("lib/assets/images/support.png", height: 190),
                  const SizedBox(height: 16),

                  const Text(
                    "Share Your Feedback",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0062C8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please select a topic below and let us know \nabout your concern.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Mood icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMoodIcon(
                          1, Icons.sentiment_very_dissatisfied, Colors.red),
                      _buildMoodIcon(
                          2, Icons.sentiment_dissatisfied, Colors.orange),
                      _buildMoodIcon(
                          3, Icons.sentiment_satisfied, Colors.amber),
                      _buildMoodIcon(
                          4, Icons.sentiment_satisfied_alt, Colors.lightGreen),
                      _buildMoodIcon(
                          5, Icons.sentiment_very_satisfied, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dropdown styled
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: feedbackType,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 13),
                          child: Text("Select topic"),
                        ),
                        isExpanded: true,
                        items: [
                          "Something is wrong with this app.",
                          "Something is wrong with the network.",
                          "Other feedback"
                        ].map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                                ),
                                if (feedbackType == item)
                                  const Icon(Icons.check, color: Colors.blue),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => feedbackType = value);
                        },
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Text input
                  TextField(
                    controller: _controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Type here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Checkbox
                  Row(
                    children: [
                      SizedBox(
                        height: 18,
                        width: 18,
                        child: Checkbox(
                          value: isIssue,
                          onChanged: (value) =>
                              setState(() => isIssue = value!),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          "This is an issue (share configuration settings of my app)",
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0062C8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text("Submit",
                          style:
                          TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
