import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/appbar/customize_appbar_screen.dart';
import '../../widgets/navbar/customize_navbar.dart';
import 'calendar_appointment.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String name;
  final String specialty;
  final String clinic;
  final String image;

  const DoctorDetailsScreen({
    super.key,
    required this.name,
    required this.specialty,
    required this.clinic,
    required this.image,
  });

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  int _selectedIndex = 0;

  String getPatientName() {
    final user = FirebaseAuth.instance.currentUser;
    // ✅ Use Firebase displayName if set, fallback to email or "Unknown"
    return user?.displayName ?? user?.email ?? "Unknown User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomizeAppBarScreen(
        onNotificationsTap: () {
          debugPrint("Notifications tapped");
        },
        onProfileTap: () {
          debugPrint("Profile tapped");
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Doctor name",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.image,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.specialty,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              widget.clinic,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Sunday – Friday (7:00 AM – 12:00 PM)",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "${widget.name} is an experienced endocrinologist with a focus on diabetes management and urinalysis interpretation. "
              "Known for precise diagnostic skills and commitment to patient education.",
              style: const TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendarAppointmentScreen(
                        doctorName: widget.name,
                        doctorSpecialty: widget.specialty,
                        doctorClinic: widget.clinic,
                        doctorImage: widget.image,
                        patientName: getPatientName(), // ✅ now dynamic
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Book Appointment",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
          debugPrint("Selected Nav Index: $_selectedIndex");
        },
      ),
    );
  }
}
