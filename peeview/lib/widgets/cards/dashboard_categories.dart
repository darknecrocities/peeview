import 'package:flutter/material.dart';
import '../../screens/scan/scan_screen.dart';
import '../../screens/manualentry/manual_entry_screen.dart';
import 'package:peeview/screens/upload/upload_screen.dart';

class DashboardCategories extends StatelessWidget {
  const DashboardCategories({super.key});

  Widget _categoryBox(BuildContext context, String title, String imagePath) {
    double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        if (title == "Scan") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanScreen()),
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
      borderRadius: BorderRadius.circular(screenWidth * 0.04),
      child: Container(
        width: screenWidth * 0.25,  // adaptive width
        height: screenWidth * 0.25, // adaptive height
        decoration: BoxDecoration(
          color: const Color(0xFF1E63D0),
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: screenWidth * 0.02,
              offset: Offset(0, screenWidth * 0.01),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: screenWidth * 0.1, // adaptive size
              height: screenWidth * 0.1,
              fit: BoxFit.contain,
            ),
            SizedBox(height: screenWidth * 0.025),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.035, // adaptive font
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenWidth * 0.025),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _categoryBox(context, "Scan", "lib/assets/images/scan.png"),
          _categoryBox(context, "Enter", "lib/assets/images/enter.png"),
          _categoryBox(context, "Upload", "lib/assets/images/upload.png"),
        ],
      ),
    );
  }
}
