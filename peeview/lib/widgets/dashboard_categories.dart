import 'package:flutter/material.dart';
import '../screens/manualentry/manual_entry_screen.dart'; // import your manual entry screen

class DashboardCategories extends StatelessWidget {
  const DashboardCategories({super.key});

  Widget _categoryItem(BuildContext context, String title, IconData icon) {
    return InkWell(
      onTap: () {
        if (title == "Test") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManualEntryScreen()),
          );
        }
      },
      borderRadius: BorderRadius.circular(40),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade100,
            child: Icon(icon, color: const Color(0xFF00247D), size: 30),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _categoryItem(context, "Test", Icons.science),
          _categoryItem(context, "Results", Icons.receipt_long),
          _categoryItem(context, "Clinics", Icons.local_hospital),
          _categoryItem(context, "Chat", Icons.chat_bubble),
        ],
      ),
    );
  }
}
