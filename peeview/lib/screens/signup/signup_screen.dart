import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import '../../widgets/cards/role_selector.dart';
import '../../widgets/textfield/text_field_input.dart';
import '../../widgets/textfield/phone_field.dart';
import 'patient/gender_screen.dart';
import 'clinic/clinic_info_screen.dart';
import 'package:peeview/widgets/navbar/customize_nav_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedRole = "Patient";
  String _countryCode = "+63";
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the fields ❌")),
      );
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match ❌")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_selectedRole == "Clinic") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClinicInfoScreen()),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Patient Sign Up
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Update Firebase displayName
      await userCredential.user?.updateDisplayName(_nameController.text.trim());
      await userCredential.user?.reload();

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": "$_countryCode${_phoneController.text.trim()}",
        "role": _selectedRole,
        "createdAt": FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GenderScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _signUpWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sign Up with Google Clicked"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _signUpWithFacebook() {
    print("Sign Up with Facebook clicked");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sign Up with Facebook Clicked"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomizeNavAuth(
        showBackButton: true,
        showSkipButton: true,
        showTitle: true,
        title: "SIGN UP",
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "I am:",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RoleSelector(
                        role: "Patient",
                        assetPath: "lib/assets/images/patient.png",
                        selectedRole: _selectedRole,
                        onSelect: (val) => setState(() => _selectedRole = val),
                      ),
                      RoleSelector(
                        role: "Clinic",
                        assetPath: "lib/assets/images/clinic.png",
                        selectedRole: _selectedRole,
                        onSelect: (val) => setState(() => _selectedRole = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFieldInput(
                    controller: _nameController,
                    hint: "Full Name",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    controller: _emailController,
                    hint: "Email Address",
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 10),
                  PhoneField(
                    controller: _phoneController,
                    countryCode: _countryCode,
                    onCountryCodeChanged: (val) => _countryCode = val,
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    controller: _passwordController,
                    hint: "Password",
                    icon: Icons.lock,
                    obscure: true,
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    controller: _confirmPasswordController,
                    hint: "Confirm Password",
                    icon: Icons.lock,
                    obscure: true,
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0062C8),
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Or"),
                      ),
                      Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: _signUpWithGoogle,
                    icon: Image.asset(
                      "lib/assets/images/google_logo.png",
                      height: 18,
                    ),
                    label: const Text("Sign Up with Google"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _signUpWithFacebook,
                    icon: Image.asset(
                      "lib/assets/images/facebookk.png",
                      height: 18,
                    ),
                    label: const Text("Sign Up with Facebook"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),

                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                          text: "Sign In",
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
