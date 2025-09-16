import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import '../../../widgets/role_selector.dart';
import 'admin_account_screen.dart';


class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String _selectedRole = "Clinic";

  // Multiple choice options
  final Map<String, bool> _services = {
    "Urine Analysis": false,
    "General Consultation": false,
    "Kidney & Neurological Care": false,
    "Diabetes Management": false,
    "Preventive Care": false,
    "Lab Testing": false,
  };

  Future<void> _continue() async {
    List<String> selectedServices = [];
    _services.forEach((key, value) {
      if (value) selectedServices.add(key);
    });

    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one service ❌")),
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
        "services": selectedServices,
        "servicesUpdatedAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Services info saved ✅")),
      );

      // Navigate to next step (Step 4)
      // Navigator.push(...);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving services info: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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

  Widget _buildServiceTiles() {
    return Column(
      children: _services.keys.map((service) {
        final isSelected = _services[service]!;
        return GestureDetector(
          onTap: () {
            setState(() {
              _services[service] = !isSelected;
            });
          },
          child: Container(
            width: double.infinity, // full width
            margin: const EdgeInsets.symmetric(vertical: 6), // spacing between tiles
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            alignment: Alignment.center, // centers the text
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00247D) : Colors.white,
              border: Border.all(color: isSelected ? const Color(0xFF00247D) : Colors.grey),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              service,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
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
                      "What Services do you offer?",
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Services checkboxes
                  // Services selectable tiles
                  _buildServiceTiles(),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                      await _continue(); // Save selected services first
                      // Navigate to AdminAccountScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminAccountScreen()),
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
                    child: Text("Step 3 of 4", style: TextStyle(fontSize: 12, color: Colors.grey)),
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

            // Back button
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
