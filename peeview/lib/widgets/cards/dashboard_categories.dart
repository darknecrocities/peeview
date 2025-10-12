import 'package:flutter/material.dart';
import '../../screens/scan/scan_screen.dart';  // ✅ Import ScanScreen
import '../../screens/manualentry/manual_entry_screen.dart';
import 'package:peeview/screens/upload/upload_screen.dart';

class DashboardCategories extends StatelessWidget {
  const DashboardCategories({super.key});

  Widget _categoryBox(BuildContext context, String title, String imagePath) {
    return InkWell(
      onTap: () {
        if (title == "Scan") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanScreen()), // ✅ Go to ScanScreen
          );
        } else if (title == "Enter") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManualEntryScreen()),
          );
        } else if (title == "Upload") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadScreen()),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF1E63D0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _categoryBox(context, "Scan", "lib/assets/images/scan.png"),
          _categoryBox(context, "Enter", "lib/assets/images/enter.png"),
          _categoryBox(context, "Upload", "lib/assets/images/upload.png"),
        ],
      ),
    );
  }
}
