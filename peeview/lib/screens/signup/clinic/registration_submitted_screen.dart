import 'package:flutter/material.dart';
import '../../login/login_screen.dart'; // adjust path as needed


class RegistrationSubmittedScreen extends StatelessWidget {
  const RegistrationSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // super white background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),

              // Centered bold blue text
              Center(
                child: Text(
                  "Registration Submitted!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00247D),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Light grey small text under main title
              Center(
                child: Text(
                  "Your clinic registration is under review.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // "What happens next?" section
              Text(
                "What happens next?",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("• We'll verify your credentials (24-48 hours)", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    SizedBox(height: 4),
                    Text("• You'll receive approval via email", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    SizedBox(height: 4),
                    Text("• Complete your clinic profile setup", style: TextStyle(fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Expected approval time
              Text(
                "Expected approval time: 1-2 business days",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const Spacer(),

              // Back to Home button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false, // removes all previous routes
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00247D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Contact info
              Center(
                child: Text(
                  "Questions? Contact\nsupport@peeview.com",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
