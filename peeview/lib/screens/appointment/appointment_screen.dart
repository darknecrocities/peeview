// File: lib/screens/appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peeview/widgets/navbar/customize_navbar.dart';
import 'package:peeview/screens/exclusive%20widgets/customize_appbar_screen.dart';
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

  /// Build doctor card widget
  Widget _buildDoctorCard({
    required String doctorName,
    required String clinic,
    required String dateTime,
    required String status,
    required String imageUrl,
    required List<Widget> actions,
  }) {
    Color statusColor;
    switch (status) {
      case "Upcoming":
        statusColor = Colors.blue;
        break;
      case "Completed":
        statusColor = Colors.green;
        break;
      case "Cancelled":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(clinic,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(dateTime,
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 12)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(status,
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          if (actions.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: actions,
            )
        ],
      ),
    );
  }

  /// Build appointments list filtered by status
  Widget _appointmentList(String filterStatus) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in to see appointments"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientName', isEqualTo: user.displayName ?? "") // ✅ FIXED
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Handle date as String (since that's how it's saved in Firestore)
          final dateRaw = data['date'];
          DateTime date;
          if (dateRaw is Timestamp) {
            date = dateRaw.toDate();
          } else if (dateRaw is String) {
            date = DateTime.tryParse(dateRaw) ?? DateTime.now();
          } else {
            return false;
          }

          // No explicit status in your data → compute it
          String status;
          if ((data['status'] ?? "").toString().isNotEmpty) {
            status = data['status'];
          } else {
            status = date.isAfter(DateTime.now())
                ? "Upcoming"
                : "Completed";
          }

          if (filterStatus == "Upcoming") {
            return status == "Upcoming";
          }
          if (filterStatus == "Completed") {
            return status == "Completed";
          }
          if (filterStatus == "Cancelled") {
            return status == "Cancelled";
          }
          return false;
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text("No appointments found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data() as Map<String, dynamic>;

            final date = (data['date'] is Timestamp)
                ? (data['date'] as Timestamp).toDate()
                : DateTime.tryParse(data['date'].toString()) ?? DateTime.now();

            final formattedDate =
            DateFormat("MMM dd, yyyy | hh:mm a").format(date);

            // Compute status if missing
            String status;
            if ((data['status'] ?? "").toString().isNotEmpty) {
              status = data['status'];
            } else {
              status = date.isAfter(DateTime.now())
                  ? "Upcoming"
                  : "Completed";
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
                  onPressed: () {
                    debugPrint("Reschedule tapped");
                  },
                  style: ElevatedButton.styleFrom(
                    // Keep the default background color
                    backgroundColor: Colors.blue, // you can remove this line if you want the theme default
                  ),
                  child: const Text(
                    "Reschedule",
                    style: TextStyle(color: Colors.white),
                  ),
                )

              ]
                  : status == "Completed"
                  ? [
                OutlinedButton(
                  onPressed: () async {
                    final data =
                    filteredDocs[index].data() as Map<String, dynamic>;
                    final docId = filteredDocs[index].id;

                    // 1️⃣ Pick a new date
                    final newDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (newDate == null) return; // user cancelled

                    // 2️⃣ Pick a new time
                    final newTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (newTime == null) return; // user cancelled

                    // 3️⃣ Combine date and time
                    final newDateTime = DateTime(
                      newDate.year,
                      newDate.month,
                      newDate.day,
                      newTime.hour,
                      newTime.minute,
                    );

                    // 4️⃣ Update Firestore appointment
                    await FirebaseFirestore.instance
                        .collection('appointments')
                        .doc(docId)
                        .update({
                      "date": newDateTime,
                      "status": "Upcoming",
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Appointment rescheduled successfully!")),
                    );
                  },
                  child: const Text("Book again"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    debugPrint("Leave a Review tapped");
                  },
                  child: const Text(
                    "Leave a Review",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ]
                  : [],


            );
          },
        );
      },
    );
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
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Center(
              child: Text(
                "My Appointment",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
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
                _appointmentList("Upcoming"),
                _appointmentList("Completed"),
                _appointmentList("Cancelled"),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ClinicScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
