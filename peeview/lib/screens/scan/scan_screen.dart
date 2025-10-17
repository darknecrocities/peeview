import 'package:flutter/material.dart';
import '../exclusive widgets/customize_appbar_screen.dart';
import '../../widgets/navbar/customize_navbar.dart';
import 'scan_upload_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  int _currentIndex = 1; // Navbar index for Scan

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomizeAppBarScreen(
        onNotificationsTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Notifications tapped")));
        },
        onProfileTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Profile tapped")));
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back Arrow
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 30),

            // Title
            const Text(
              "Scan Results",
              style: TextStyle(
                color: Color(0xFF0062C8),
                fontSize: 44,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Scan your urine test report using your \ncamera.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 20),

            // Fixed Checkboxes
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                _FixedCheckbox(
                  label: "Capture a clear photo of your lab report",
                ),
                _FixedCheckbox(label: "Automatic text extraction (OCR)"),
                _FixedCheckbox(label: "AI analysis when complete"),
              ],
            ),

            const SizedBox(height: 20),

            // What you'll need
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "What you’ll need:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "• Lab report\n• Good lighting for a clear photo",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),

            const Spacer(),

            // Get Started Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScanUploadScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0062C8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Note: This app provides health guidance only and does not replace professional medical advice.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// 🔹 Fixed Checkbox Widget (always checked, non-editable)
class _FixedCheckbox extends StatelessWidget {
  final String label;
  const _FixedCheckbox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_box, color: Color(0xFF0062C8), size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
