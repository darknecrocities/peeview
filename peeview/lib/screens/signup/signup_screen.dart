import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'gender_screen.dart'; // adjust path



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
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match ❌")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": "$_countryCode${_phoneController.text.trim()}",
        "role": _selectedRole,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully ✅")),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildRoleOption(String role, String assetPath) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00247D) : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            Image.asset(assetPath, height: 70),
            const SizedBox(height: 6),
            Text(
              role.toUpperCase(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF00247D) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    TextInputType? type,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      height: 50, // fixed height for uniformity
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
      ),
      child: Row(
        children: [
          // Country code picker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
            ),
            child: CountryCodePicker(
              onChanged: (code) {
                setState(() => _countryCode = code.dialCode!);
              },
              initialSelection: "PH",
              favorite: const ["+63", "PH"],
              showFlag: true,
              showDropDownButton: true,
              showFlagDialog: true,
              textStyle: const TextStyle(fontSize: 14, color: Colors.black),
              padding: EdgeInsets.zero,
            ),
          ),

          // Phone number field
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Phone Number",
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "SIGN UP",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00247D),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Role
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
                      _buildRoleOption("Patient", "lib/assets/images/patient.png"),
                      _buildRoleOption("Clinic", "lib/assets/images/clinic.png"),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Fields
                  _buildTextField(
                      controller: _nameController,
                      hint: "Full Name",
                      icon: Icons.person),
                  const SizedBox(height: 10),
                  _buildTextField(
                      controller: _emailController,
                      hint: "Email Address",
                      icon: Icons.email),
                  const SizedBox(height: 10),

                  _buildPhoneField(),
                  const SizedBox(height: 10),

                  _buildTextField(
                      controller: _passwordController,
                      hint: "Password",
                      icon: Icons.lock,
                      obscure: true),
                  const SizedBox(height: 10),
                  _buildTextField(
                      controller: _confirmPasswordController,
                      hint: "Confirm Password",
                      icon: Icons.lock,
                      obscure: true),

                  const SizedBox(height: 16),

                  // Button
                  // Continue Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      _signUp();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GenderScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00247D),
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

// Space below Continue button
                  const SizedBox(height: 16),

// Or Divider
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

// Space below divider
                  const SizedBox(height: 16),

// Google Sign Up Button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GenderScreen()),
                      );
                    },
                    icon: Image.asset("lib/assets/images/google_logo.png", height: 18),
                    label: const Text("Sign Up with Google"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),

// Space between Google and Facebook buttons
                  const SizedBox(height: 12),

// Facebook Sign Up Button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GenderScreen()),
                      );
                    },
                    icon: Image.asset("lib/assets/images/facebookk.png", height: 18),
                    label: const Text("Sign Up with Facebook"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),


                  const SizedBox(height: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "By continuing, you agree to our",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "",
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Terms of Service",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: Open Terms of Service link
                                  print("Terms of Service clicked");
                                },
                            ),
                            const TextSpan(
                              text: " and ",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: "Privacy Policy",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: Open Privacy Policy link
                                  print("Privacy Policy clicked");
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            // 🔹 Back button (top-left)
            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
