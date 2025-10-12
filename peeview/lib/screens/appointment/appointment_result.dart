import 'package:flutter/material.dart';
import '../exclusive widgets/customize_appbar_screen.dart';
import '../../widgets/navbar/customize_navbar.dart';
import 'package:peeview/screens/dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AppointmentResultScreen extends StatefulWidget {
  final String doctorName;
  final String patientName;
  final DateTime date;
  final String time;
  final String doctorImage; // ✅ added for image
  final String doctorSpecialty;
  final String doctorClinic;

  const AppointmentResultScreen({
    super.key,
    required this.doctorName,
    required this.patientName,
    required this.date,
    required this.time,
    required this.doctorImage,
    required this.doctorSpecialty,
    required this.doctorClinic,
  });

  @override
  State<AppointmentResultScreen> createState() =>
      _AppointmentResultScreenState();
}

class _AppointmentResultScreenState extends State<AppointmentResultScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? patientData;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          patientData = doc.data();
        });
      }
    } catch (e) {
      debugPrint("Error fetching patient info: $e");
    }
  }

  int _calculateAge(String birthdateStr) {
    try {
      DateTime birthDate = DateTime.parse(birthdateStr);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0; // fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = patientData?['name'] ?? widget.patientName;
    final gender = patientData?['gender'] ?? "—";
    final birthdate = patientData?['birthdate'];
    final age = (birthdate != null) ? _calculateAge(birthdate) : null;

    return Scaffold(
      appBar: CustomizeAppBarScreen(
        onNotificationsTap: () {},
        onProfileTap: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Appointment",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Doctor card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.doctorImage,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  widget.doctorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    "${widget.doctorSpecialty}\n${widget.doctorClinic}\n${_formatDate(widget.date)} | ${widget.time}"),
              ),
            ),

            const SizedBox(height: 20),

            // Appointment Info
            const Text("Scheduled Appointment",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              _formatDate(widget.date),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${widget.time} - (30 minutes)",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              widget.doctorClinic,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),


            // Patient Info
            const Text(
              "Patient Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Full Name: $name",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            Text(
              "Gender: $gender",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            Text(
              "Age: ${age ?? '—'}",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const Text(
              "Problem: — (No problem description provided)",
              style: TextStyle(color: Colors.grey),
            ),



            const SizedBox(height: 100),

            // Back button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                  const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  "Back to Dashboard",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }
}

