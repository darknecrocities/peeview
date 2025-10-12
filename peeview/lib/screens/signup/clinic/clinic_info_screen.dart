import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'contact_location_screen.dart';
import '../../../widgets/textfield/text_field_input.dart';
import '../../../widgets/cards/role_selector.dart';

class ClinicInfoScreen extends StatefulWidget {
  const ClinicInfoScreen({super.key});

  @override
  State<ClinicInfoScreen> createState() => _ClinicInfoScreenState();
}

class _ClinicInfoScreenState extends State<ClinicInfoScreen> {
  final TextEditingController _clinicNameController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _clinicTypeController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _clinicEmailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _countryCode = "+63";
  bool _isLoading = false;
  String _selectedRole = "Clinic";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _clinicNameController.dispose();
    _licenseController.dispose();
    _clinicTypeController.dispose();
    _contactPersonController.dispose();
    _clinicEmailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_clinicNameController.text.trim().isEmpty ||
        _licenseController.text.trim().isEmpty ||
        _clinicTypeController.text.trim().isEmpty ||
        _contactPersonController.text.trim().isEmpty ||
        _clinicEmailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the fields ❌")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in ❌")));
        setState(() => _isLoading = false);
        return;
      }

      await _firestore.collection("clinics").doc(user.uid).set({
        "clinicName": _clinicNameController.text.trim(),
        "licenseNumber": _licenseController.text.trim(),
        "clinicType": _clinicTypeController.text.trim(),
        "contactPerson": _contactPersonController.text.trim(),
        "clinicEmail": _clinicEmailController.text.trim(),
        "phone": "$_countryCode${_phoneController.text.trim()}",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Clinic info saved ✅")));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ContactLocationScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving clinic info: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPhoneField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
            ),
            child: CountryCodePicker(
              onChanged: (code) =>
                  setState(() => _countryCode = code.dialCode!),
              initialSelection: "PH",
              favorite: const ["+63", "PH"],
              showFlag: true,
              showDropDownButton: true,
              showFlagDialog: true,
              textStyle: const TextStyle(fontSize: 14, color: Colors.black),
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Phone Number",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RoleSelector(
          role: "Patient",
          assetPath: "lib/assets/images/patient.png",
          selectedRole: _selectedRole,
          onSelect: (val) => setState(() => _selectedRole = val),
          isLocked: true, // patient is locked
        ),
        RoleSelector(
          role: "Clinic",
          assetPath: "lib/assets/images/clinic.png",
          selectedRole: _selectedRole,
          onSelect: (val) => setState(() => _selectedRole = val),
          isLocked: false, // clinic is selectable
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
                    "Clinic Information",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00247D),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "I am:",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildRoleSelector(),
                  const SizedBox(height: 14),
                  TextFieldInput(
                    controller: _clinicNameController,
                    hint: "Clinic Name",
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    controller: _licenseController,
                    hint: "License / Accreditation Number",
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    controller: _clinicTypeController,
                    hint: "Clinic Type",
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    controller: _contactPersonController,
                    hint: "Primary Contact Person",
                  ),
                  const SizedBox(height: 10),
                  TextFieldInput(
                    controller: _clinicEmailController,
                    hint: "Clinic Email Address",
                  ),
                  const SizedBox(height: 10),
                  _buildPhoneField(),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFF0062C8),
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
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Step 1 of 4",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: "Terms of Service",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print("Terms clicked");
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
                                  print("Privacy clicked");
                                },
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
