import 'package:flutter/material.dart';
import '../../widgets/customize_navbar.dart';
import '../customize_appbar_screen.dart';
import 'faq_inquiry_screen.dart'; // ✅ FAQ screen
import 'feedback_screen.dart';   // ✅ Feedback screen

class SupportFeedbackScreen extends StatefulWidget {
  const SupportFeedbackScreen({super.key});

  @override
  State<SupportFeedbackScreen> createState() => _SupportFeedbackScreenState();
}

class _SupportFeedbackScreenState extends State<SupportFeedbackScreen> {
  int _currentIndex = 4; // Profile tab active

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    // TODO: add navigation logic if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomizeAppBarScreen(
        onNotificationsTap: () {
          // 👉 Navigate to notifications screen
          Navigator.pushNamed(context, "/notifications");
        },
        onProfileTap: () {
          // 👉 Navigate to profile screen
          Navigator.pushNamed(context, "/profile");
        },
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Heading
              const Text(
                "Support",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // First Row: Call Us + Mail Us
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildVerticalCard(
                      icon: Icons.phone,
                      title: "Call Us",
                      subtitle: "Talk to our executive",
                      onTap: () => debugPrint("Call Us tapped"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildVerticalCard(
                      icon: Icons.mail,
                      title: "Mail Us",
                      subtitle: "Mail to our executive",
                      onTap: () => debugPrint("Mail Us tapped"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // FAQs → opens FAQInquiryScreen
              _buildCenteredCard(
                icon: Icons.help_outline,
                title: "FAQs",
                subtitle: "Discover App Information",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FAQInquiryScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Feedback → opens FeedbackScreen
              _buildCenteredCard(
                icon: Icons.feedback_outlined,
                title: "Feedback",
                subtitle: "Tell us what you think of our App",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeedbackScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  /// Card with icon on top, text below (Call Us / Mail Us)
  Widget _buildVerticalCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
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
              radius: 28,
              backgroundColor: const Color(0xFFE8F0FE),
              child: Icon(icon, color: const Color(0xFF0062C8), size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Card with left icon + text (FAQs / Feedback)
  Widget _buildCenteredCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        width: double.infinity,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE8F0FE),
              child: Icon(icon, color: const Color(0xFF0062C8), size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
