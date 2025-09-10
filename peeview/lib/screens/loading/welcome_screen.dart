import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Super white background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 80),

              // Welcome Image
              Center(
                child: Image.asset(
                  'lib/assets/images/welcome.png', // Make sure this image exists in assets
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 24),

              // Success text
              const Text(
                "Your account has been registered successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),

              const Spacer(),

              // Go to Dashboard Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Dashboard screen
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Go to Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Setup Profile Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Setup Profile screen
                    Navigator.pushReplacementNamed(context, '/setup_profile');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade200,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Setup Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Support text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Questions? Contact ",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: "support@peeview.com",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                      // Optional: Make email clickable
                      recognizer: null,
                    ),
                  ],
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
