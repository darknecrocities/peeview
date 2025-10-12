import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/customize_bottom_navbar.dart';
import '../widgets/dashboard_categories.dart';
import '../widgets/customize_app_bar_dash.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _appointmentsList() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in to see appointments"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientName', isEqualTo: user.displayName)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("No upcoming appointments"),
          );
        }

        final upcomingDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final dateRaw = data['date'];
          if (dateRaw == null) return false;
          DateTime date;
          if (dateRaw is Timestamp) {
            date = dateRaw.toDate();
          } else if (dateRaw is String) {
            date = DateTime.tryParse(dateRaw) ?? DateTime.now();
          } else {
            return false;
          }
          return date.isAfter(DateTime.now());
        }).toList();

        return Column(
          children: upcomingDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            DateTime date;
            final dateRaw = data['date'];
            if (dateRaw is Timestamp) {
              date = dateRaw.toDate();
            } else if (dateRaw is String) {
              date = DateTime.tryParse(dateRaw) ?? DateTime.now();
            } else {
              date = DateTime.now();
            }

            return _appointmentCard(
              doctorName: data['doctorName'] ?? "Unknown Doctor",
              clinic: data['doctorClinic'] ?? "Unknown Clinic",
              date: date,
              time: data['time'] ?? "—",
              imageUrl:
              data['doctorImage'] ??
                  "https://randomuser.me/api/portraits/men/32.jpg",
            );
          }).toList(),
        );
      },
    );
  }

  Widget _appointmentCard({
    required String doctorName,
    required String clinic,
    required DateTime date,
    required String time,
    required String imageUrl,
  }) {
    final formattedDate = DateFormat("EEE, dd MMM yyyy").format(date);

    return Card(
      color: const Color(0xFF0062C8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      clinic,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(time, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _clinicCard(String name, String distance, bool isOpen) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0062C8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: Color(0xFF0062C8), size: 28),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            distance,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            isOpen ? "Open" : "Closed",
            style: TextStyle(
              color: isOpen ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomizeAppBarDash(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search results, doctors...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0XFF063365),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0XFF063365)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0XFF063365)),
                  ),
                ),
              ),
              SizedBox(height: 30),
              const DashboardCategories(),
              SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0XFF0062C8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Stay Hydrated",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Drinking at least 8 glasses of water a day helps flush out toxins, keeps your kidneys healthy, and lowers the risk of urinary tract infections.",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.water_drop,
                      size: 100,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Upcoming Appointment",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              _appointmentsList(),
              const SizedBox(height: 30),
              Text(
                "Find the Nearest Clinic",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _clinicCard("HealthPlus Clinic", "2.5 km", true),
                    const SizedBox(width: 12),
                    _clinicCard("VitalCare Medical Center", "5.2 km", true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
