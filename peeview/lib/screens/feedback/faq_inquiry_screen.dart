import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../customize_appbar_screen.dart';
import 'feedback_screen.dart';

class FAQInquiryScreen extends StatelessWidget {
  const FAQInquiryScreen({super.key});

  Future<void> _saveSelectionAndNavigate(
      BuildContext context, String category) async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection("faqSelections").add({
      "userId": user?.uid,
      "category": category,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // Navigate to FeedbackScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackScreen(category: category),
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE8F0FE),
              child: Icon(icon, color: const Color(0xFF0062C8)),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ✅ Use custom appbar
      appBar: CustomizeAppBarScreen(
        onNotificationsTap: () {
          Navigator.pushNamed(context, "/notifications");
        },
        onProfileTap: () {
          Navigator.pushNamed(context, "/profile");
        },
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "FAQs",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                "lib/assets/images/faq.png", // ✅ replace with your asset
                height: 150,
              ),
              const SizedBox(height: 16),
              const Text(
                "How can we help?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0062C8),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Welcome to our app support. Ask anything. Our support community can help you find answers to your queries.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 24),

              // 4 tiles
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildTile(
                    title: "App",
                    icon: Icons.phone_iphone,
                    onTap: () => _saveSelectionAndNavigate(context, "App"),
                  ),
                  _buildTile(
                    title: "General",
                    icon: Icons.chat_bubble_outline,
                    onTap: () =>
                        _saveSelectionAndNavigate(context, "General"),
                  ),
                  _buildTile(
                    title: "Usage",
                    icon: Icons.pie_chart_outline,
                    onTap: () => _saveSelectionAndNavigate(context, "Usage"),
                  ),
                  _buildTile(
                    title: "Troubleshooting",
                    icon: Icons.settings_outlined,
                    onTap: () =>
                        _saveSelectionAndNavigate(context, "Troubleshooting"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
