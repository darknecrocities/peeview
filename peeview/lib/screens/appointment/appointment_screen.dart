import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peeview/widgets/appbar/customize_app_bar_dash.dart';
import 'package:peeview/widgets/navbar/customize_navbar.dart';
import 'package:peeview/screens/map/clinic_screen.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1; // Calendar is active
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget _buildDoctorCard({
    required String doctorName,
    required String clinic,
    required String dateTime,
    required String status,
    required String imageUrl,
    required List<Widget> actions,
    required double screenWidth,
    required double screenHeight,
  }) {
    // Status color mapping
    final Map<String, Color> statusColors = {
      "Upcoming": Colors.blue,
      "Completed": Colors.green,
      "Cancelled": Colors.red,
    };
    final statusColor = statusColors[status] ?? Colors.grey;

    // Use smaller dimension to scale for portrait/landscape
    final double baseWidth = screenWidth < screenHeight ? screenWidth : screenHeight;

    // Dynamic sizing
    final double cardPadding = baseWidth * 0.035;
    final double avatarRadius = baseWidth * 0.08;
    final double spacingSmall = baseWidth * 0.015;
    final double spacingMedium = baseWidth * 0.03;
    final double borderRadius = baseWidth * 0.03;
    final double statusFontSize = baseWidth * 0.025;
    final double doctorNameSize = baseWidth * 0.045;
    final double clinicSize = baseWidth * 0.035;
    final double dateSize = baseWidth * 0.03;
    final double buttonHeight = baseWidth * 0.09;

    return Container(
      margin: EdgeInsets.only(bottom: spacingMedium),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundImage: NetworkImage(imageUrl),
              ),
              SizedBox(width: spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: doctorNameSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: spacingSmall),
                    Text(
                      clinic,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: clinicSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: spacingSmall),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dateTime,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: dateSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: spacingSmall),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: baseWidth * 0.025,
                            vertical: baseWidth * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(baseWidth * 0.02),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: statusFontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            SizedBox(height: spacingMedium),
            Row(
              children: actions.map((w) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: baseWidth * 0.01),
                    height: buttonHeight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: w,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }


  Widget _appointmentList(String filterStatus, double screenWidth, double screenHeight) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in to see appointments"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientName', isEqualTo: user.displayName ?? "")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final dateRaw = data['date'];
          DateTime date;
          if (dateRaw is Timestamp) {
            date = dateRaw.toDate();
          } else if (dateRaw is String) {
            date = DateTime.tryParse(dateRaw) ?? DateTime.now();
          } else {
            return false;
          }

          String status;
          if ((data['status'] ?? "").toString().isNotEmpty) {
            status = data['status'];
          } else {
            status = date.isAfter(DateTime.now()) ? "Upcoming" : "Completed";
          }

          return filterStatus == status;
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text("No appointments found"));
        }

        return ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data() as Map<String, dynamic>;
            final date = (data['date'] is Timestamp)
                ? (data['date'] as Timestamp).toDate()
                : DateTime.tryParse(data['date'].toString()) ?? DateTime.now();
            final formattedDate = DateFormat("MMM dd, yyyy | hh:mm a").format(date);

            String status;
            if ((data['status'] ?? "").toString().isNotEmpty) {
              status = data['status'];
            } else {
              status = date.isAfter(DateTime.now()) ? "Upcoming" : "Completed";
            }

            return _buildDoctorCard(
              doctorName: data['doctorName'] ?? "Unknown Doctor",
              clinic: data['doctorClinic'] ?? "Unknown Clinic",
              dateTime: formattedDate,
              status: status,
              imageUrl: data['doctorImage'] ??
                  "https://randomuser.me/api/portraits/men/32.jpg",
              actions: status == "Upcoming"
                  ? [
                OutlinedButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('appointments')
                        .doc(filteredDocs[index].id)
                        .update({"status": "Cancelled"});
                  },
                  child: const Text("Cancel Appointment"),
                ),
                ElevatedButton(
                  onPressed: () => debugPrint("Reschedule tapped"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    "Reschedule",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ]
                  : status == "Completed"
                  ? [
                OutlinedButton(
                  onPressed: () async {
                    final docId = filteredDocs[index].id;
                    final newDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (newDate == null) return;
                    final newTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (newTime == null) return;
                    final newDateTime = DateTime(
                      newDate.year,
                      newDate.month,
                      newDate.day,
                      newTime.hour,
                      newTime.minute,
                    );
                    await FirebaseFirestore.instance
                        .collection('appointments')
                        .doc(docId)
                        .update({
                      "date": newDateTime,
                      "status": "Upcoming",
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Appointment rescheduled successfully!"),
                      ),
                    );
                  },
                  child: const Text("Book again"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () => debugPrint("Leave a Review tapped"),
                  child: const Text(
                    "Leave a Review",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ]
                  : [],
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomizeAppBarDash(),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                screenWidth * 0.04, screenHeight * 0.015, screenWidth * 0.04, screenHeight * 0.01),
            child: Center(
              child: Text(
                "My Appointment",
                style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF0062C8),
            labelColor: const Color(0xFF0062C8),
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: screenWidth * 0.04),
            tabs: const [
              Tab(text: "Upcoming"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _appointmentList("Upcoming", screenWidth, screenHeight),
                _appointmentList("Completed", screenWidth, screenHeight),
                _appointmentList("Cancelled", screenWidth, screenHeight),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ClinicScreen()),
          );
        },
        backgroundColor: const Color(0xFF0062C8),
        child: Icon(Icons.add, size: screenWidth * 0.07, color: Colors.white),
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
