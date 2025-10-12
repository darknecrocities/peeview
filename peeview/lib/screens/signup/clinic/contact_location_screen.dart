import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import '../../../widgets/textfield/text_field_input.dart';
import '../../../widgets/cards/role_selector.dart';
import 'service_screen.dart';

class ContactLocationScreen extends StatefulWidget {
  const ContactLocationScreen({super.key});

  @override
  State<ContactLocationScreen> createState() => _ContactLocationScreenState();
}

class _ContactLocationScreenState extends State<ContactLocationScreen> {
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String _selectedRole = "Clinic"; // role is clinic

  @override
  void dispose() {
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _countryController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_address1Controller.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _provinceController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty ||
        _zipController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields ❌")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in ❌")),
        );
        setState(() => _isLoading = false);
        return;
      }

      await _firestore.collection("clinics").doc(user.uid).update({
        "addressLine1": _address1Controller.text.trim(),
        "addressLine2": _address2Controller.text.trim(),
        "city": _cityController.text.trim(),
        "province": _provinceController.text.trim(),
        "country": _countryController.text.trim(),
        "zip": _zipController.text.trim(),
        "locationUpdatedAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location info saved ✅")),
      );

      // Navigate to next step
      // Navigator.push(...);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving location info: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildZipCityRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFieldInput(controller: _cityController, hint: "City/Municipality"),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextFieldInput(controller: _zipController, hint: "Zip/Postal Code"),
        ),
      ],
    );
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
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00247D),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Role selector
                  _buildRoleSelector(),
                  const SizedBox(height: 14),

                  // Small label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Clinic & Location",
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 8),


                  // Address fields
                  TextFieldInput(controller: _address1Controller, hint: "Address Line 1"),
                  const SizedBox(height: 10),
                  TextFieldInput(controller: _address2Controller, hint: "Address Line 2 (Optional)"),
                  const SizedBox(height: 10),
                  TextFieldInput(controller: _provinceController, hint: "Province"),
                  const SizedBox(height: 10),
                  _buildZipCityRow(),
                  const SizedBox(height: 10),
                  TextFieldInput(controller: _countryController, hint: "Country"),
                  const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                    await _continue(); // Save the data first
                    // Navigate to ServiceScreen after successful save
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ServiceScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00247D),
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Continue",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.center,
                    child: Text("Step 2 of 4", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const SizedBox(height: 16),

                  // Terms & Privacy
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("By continuing, you agree to our", style: TextStyle(fontSize: 14, color: Colors.black)),
                      const SizedBox(height: 4),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "",
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Terms of Service",
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()..onTap = () { print("Terms clicked"); },
                            ),
                            const TextSpan(text: " and ", style: TextStyle(color: Colors.black)),
                            TextSpan(
                              text: "Privacy Policy",
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()..onTap = () { print("Privacy clicked"); },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
