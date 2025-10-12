import 'package:flutter/material.dart';
import 'login_input.dart'; // ⬅️ Import your login input page
import '../signup/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Super white background
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // 🔹 Logo
            Center(
              child: Image.asset(
                "lib/assets/images/app_logo_text.png",
                height: 200,
              ),
            ),

            const Spacer(),

            // 🔹 Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Sign Up Button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                      // TODO: Add signup navigation
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00247D)), // ✅ outline blue
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.white, // ✅ white background
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color(0xFF00247D), // ✅ blue text
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      // ⬅️ Navigate to login_input.dart
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginInput(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0062C8), // ✅ blue background
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white, // ✅ white text
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
