import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/navbar/customize_navbar.dart';
import '../widgets/cards/dashboard_categories.dart';
import '../widgets/appbar/customize_app_bar_dash.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> healthTips = [
    {
      "title": "Stay Hydrated",
      "desc":
      "Drinking at least 8 glasses of water a day helps flush out toxins, keeps your kidneys healthy, and lowers the risk of urinary tract infections.",
      "icon": Icons.water_drop,
      "color": Color(0XFF0062C8),
    },
    {
      "title": "Eat a Balanced Diet",
      "desc":
      "Including fruits, vegetables, and fiber in your meals supports overall wellness, and can help prevent conditions that show up in urinalysis results.",
      "icon": Icons.food_bank_outlined,
      "color": Color(0xFF003366),
    },
    {
      "title": "Don’t Hold Your Urine",
      "desc":
      "Holding urine for long periods can increase the risk of bacterial growth that leads to infections. Make sure to go when you feel the urge.",
      "icon": Icons.restore_from_trash_outlined,
      "color": Color(0xFF4169E1),
    },
    {
      "title": "Track Your Results",
      "desc":
      "Regularly checking and comparing your urinalysis results helps you spot changes early and take action before health issues get worse.",
      "icon": Icons.insert_chart_outlined,
      "color": Color(0xFF87CEFA),
    },
  ];

  Map<String, dynamic> getRandomTip() {
    final random = Random();
    return healthTips[random.nextInt(healthTips.length)];
  }

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

  Widget _healthTipCard() {
    final tip = getRandomTip();
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: tip['color'],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title'],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenWidth * 0.04),
                Text(
                  tip['desc'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.032,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            tip['icon'],
            size: screenWidth * 0.18,
            color: Colors.white,
          ),
        ],
      ),
    );
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
              data['doctorImage'] ?? "https://randomuser.me/api/portraits/men/32.jpg",
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
    double screenWidth = MediaQuery.of(context).size.width;
    final formattedDate = DateFormat("EEE, dd MMM yyyy").format(date);

    return Card(
      color: const Color(0xFF0062C8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.07,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                SizedBox(width: screenWidth * 0.03),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.01),
                      Text(
                        clinic,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: screenWidth * 0.035, color: Colors.white),
                    SizedBox(width: screenWidth * 0.02),
                    Text(formattedDate,
                        style:
                        TextStyle(color: Colors.white, fontSize: screenWidth * 0.035)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: screenWidth * 0.035, color: Colors.white),
                    SizedBox(width: screenWidth * 0.02),
                    Text(time,
                        style:
                        TextStyle(color: Colors.white, fontSize: screenWidth * 0.035)),
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Set width as 45% of screen width for horizontal list
    double cardWidth = screenWidth * 0.45;

    // Scale text sizes and icon sizes dynamically
    double iconSize = cardWidth * 0.18;
    double titleSize = cardWidth * 0.08;
    double subtitleSize = cardWidth * 0.065;
    double spacing = cardWidth * 0.02;
    double padding = cardWidth * 0.06;

    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0062C8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: const Color(0xFF0062C8),
            size: iconSize,
          ),
          SizedBox(height: spacing),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: spacing / 1.5),
          Flexible(
            child: Text(
              distance,
              style: TextStyle(
                color: Colors.grey,
                fontSize: subtitleSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: spacing / 1.5),
          Text(
            isOpen ? "Open" : "Closed",
            style: TextStyle(
              color: isOpen ? Colors.green : Colors.red,
              fontSize: subtitleSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomizeAppBarDash(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenWidth * 0.08),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search results, doctors...",
                  prefixIcon: const Icon(Icons.search, color: Color(0XFF063365)),
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
              SizedBox(height: screenWidth * 0.08),
              const DashboardCategories(),
              SizedBox(height: screenWidth * 0.08),
              _healthTipCard(),
              SizedBox(height: screenWidth * 0.08),
              Text(
                "Upcoming Appointment",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
              ),
              SizedBox(height: screenWidth * 0.04),
              _appointmentsList(),
              SizedBox(height: screenWidth * 0.08),
              Text(
                "Find the Nearest Clinic",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
              ),
              SizedBox(height: screenWidth * 0.03),
              SizedBox(
                height: screenWidth * 0.4,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  children: [
                    _clinicCard("HealthPlus Clinic", "2.5 km", true),
                    SizedBox(width: screenWidth * 0.03),
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
