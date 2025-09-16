import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../widgets/role_selector.dart';
import 'registration_submitted_screen.dart';


class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  String _selectedRole = "Clinic";

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  bool _agreeTerms = false;
  bool _verifyInfo = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildRoleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoleSelector(
          role: "Patient",
          assetPath: "lib/assets/images/patient.png",
          selectedRole: _selectedRole,
          onSelect: (val) => setState(() => _selectedRole = val),
          isLocked: true,
        ),
        const SizedBox(width: 16),
        RoleSelector(
          role: "Clinic",
          assetPath: "lib/assets/images/clinic.png",
          selectedRole: _selectedRole,
          onSelect: (val) => setState(() => _selectedRole = val),
          isLocked: false,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields ❌")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match ❌")),
      );
      return;
    }

    if (!_agreeTerms || !_verifyInfo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please check all required boxes ❌")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement saving data to Firebase or your backend

    setState(() => _isLoading = false);

    // Navigate to Registration Submitted Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const RegistrationSubmittedScreen(),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00247D),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildRoleSelector(),
                  const SizedBox(height: 14),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Admin Account Verification",
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Text fields with icons
                  _buildTextField(
                    controller: _fullNameController,
                    hint: "Administrator Full Name",
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _emailController,
                    hint: "Administrator Email",
                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _passwordController,
                    hint: "Password",
                    obscureText: !_passwordVisible,
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: "Confirm Password",
                    obscureText: !_confirmPasswordVisible,
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Smaller checkboxes

                  // Centered, aligned smaller checkboxes
                  // Centered, vertically-aligned smaller checkboxes
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: Checkbox(
                              value: _agreeTerms,
                              onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: RichText(
                              textAlign: TextAlign.start,
                              text: TextSpan(
                                text: "I agree to PeeView's ",
                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                                children: [
                                  TextSpan(
                                    text: "Terms of Service",
                                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11),
                                    recognizer: TapGestureRecognizer()..onTap = () { print("Terms clicked"); },
                                  ),
                                  const TextSpan(text: " and ", style: TextStyle(fontSize: 11)),
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11),
                                    recognizer: TapGestureRecognizer()..onTap = () { print("Privacy clicked"); },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: Checkbox(
                              value: _verifyInfo,
                              onChanged: (val) => setState(() => _verifyInfo = val ?? false),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "I verify all information provided is accurate",
                              textAlign: TextAlign.start,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 79),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00247D),
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Submit for review",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.center,
                    child: Text("Step 4 of 4", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
