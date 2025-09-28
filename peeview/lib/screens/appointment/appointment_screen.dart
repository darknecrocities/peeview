// File: lib/screens/appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:peeview/widgets/customize_navbar.dart';
import 'package:peeview/screens/customize_appbar_screen.dart';

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
              offset: const Offset(0, 2)),
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
                    ]),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: actions,
          )
        ],
      ),
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
          // Section Title
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


          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Upcoming"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled",),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // UPCOMING
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDoctorCard(
                      doctorName: "Dr. Antonio Dela Cruz, MD",
                      clinic: "HealthPlus Clinic",
                      dateTime: "August 22, 2025 | 11:00 AM",
                      status: "Upcoming",
                      imageUrl:
                      "https://randomuser.me/api/portraits/men/32.jpg",
                      actions: [
                        OutlinedButton(
                          onPressed: () {
                            debugPrint("Cancel Appointment tapped");
                          },
                          child: const Text("Cancel Appointment"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            debugPrint("Reschedule tapped");
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text("Reschedule"),
                        ),
                      ],
                    ),
                  ],
                ),

                // COMPLETED
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDoctorCard(
                      doctorName: "Dr. Antonio Dela Cruz, MD",
                      clinic: "HealthPlus Clinic",
                      dateTime: "August 22, 2025 | 11:00 AM",
                      status: "Completed",
                      imageUrl:
                      "https://randomuser.me/api/portraits/men/32.jpg",
                      actions: [
                        OutlinedButton(
                          onPressed: () {
                            debugPrint("Book again tapped");
                          },
                          child: const Text("Book again"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            debugPrint("Leave a Review tapped");
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text("Leave a Review"),
                        ),
                      ],
                    ),
                    _buildDoctorCard(
                      doctorName: "Dr. Isabelle Ramos, MD",
                      clinic: "MediCare Wellness Center",
                      dateTime: "July 15, 2025 | 09:00 AM",
                      status: "Completed",
                      imageUrl:
                      "https://randomuser.me/api/portraits/women/44.jpg",
                      actions: [
                        OutlinedButton(
                          onPressed: () {
                            debugPrint("Book again tapped");
                          },
                          child: const Text("Book again"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            debugPrint("Leave a Review tapped");
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text("Leave a Review"),
                        ),
                      ],
                    ),
                  ],
                ),

                // CANCELLED
                ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _buildDoctorCard(
                      doctorName: "Dr. Antonio Dela Cruz, MD",
                      clinic: "HealthPlus Clinic",
                      dateTime: "September 10, 2025 | 10:00 AM",
                      status: "Cancelled",
                      imageUrl:
                      "https://randomuser.me/api/portraits/men/32.jpg",
                      actions: [],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      // Floating Add Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("Add appointment tapped");
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
