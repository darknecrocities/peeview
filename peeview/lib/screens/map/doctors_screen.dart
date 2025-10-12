import 'package:flutter/material.dart';
import '/widgets/customize_appbar_screen.dart';
import '/widgets/customize_navbar.dart';
import 'doctor_details_screen.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> doctors = [
    {
      "name": "Dr. Antonio Dela Cruz, MD",
      "specialty": "General Practitioner / Urinalysis & Preventive Care",
      "clinic": "HealthPlus Clinic – Quezon City",
      "image": "https://randomuser.me/api/portraits/men/32.jpg",
    },
    {
      "name": "Dr. Lara Bautista, MD",
      "specialty": "Women’s Health / OB-GYN",
      "clinic": "HealthPlus Clinic – Quezon City",
      "image": "https://randomuser.me/api/portraits/women/44.jpg",
    },
    {
      "name": "Dr. Rafael Moreno, MD",
      "specialty": "Endocrinology / Diabetes & Kidney Disorders",
      "clinic": "HealthPlus Clinic – Quezon City",
      "image": "https://randomuser.me/api/portraits/men/46.jpg",
    },
    {
      "name": "Dr. Isabelle Ramos, MD",
      "specialty": "Family Medicine / Preventive Care",
      "clinic": "HealthPlus Clinic – Quezon City",
      "image": "https://randomuser.me/api/portraits/women/52.jpg",
    },
    {
      "name": "Dr. Miguel Alvarez, MD",
      "specialty": "Urology / Urinary Tract & Kidney Health",
      "clinic": "HealthPlus Clinic – Quezon City",
      "image": "https://randomuser.me/api/portraits/men/60.jpg",
    },
    {
      "name": "Dr. Grace Lim, MD",
      "specialty": "Internal Medicine / Nephrology",
      "clinic": "HealthPlus Clinic – Quezon City",
      "image": "https://randomuser.me/api/portraits/women/68.jpg",
    },
  ];

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
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            "Our Doctors",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorDetailsScreen(
                          name: doctor["name"]!,
                          specialty: doctor["specialty"]!,
                          clinic: doctor["clinic"]!,
                          image: doctor["image"]!,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          doctor["image"]!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        doctor["name"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor["specialty"]!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            doctor["clinic"]!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
