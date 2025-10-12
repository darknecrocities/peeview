import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/appointment/appointment_screen.dart';
import '../screens/chat/message_screen.dart';

class CustomizeNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomizeNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF00247D),
          unselectedItemColor: Colors.grey,
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == 0) {
              // Dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            } else if (index == 1) {
              // Appointments
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentScreen(),
                ),
              );
            } else if (index == 3) {
              // Appointments
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MessageScreen()),
              );
            } else if (index == 4) {
              // Profile
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            } else {
              onTap(index);
            }
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 28),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, size: 26),
              label: "",
            ),
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: ""),
            // Space for logo
            BottomNavigationBarItem(
              icon: Icon(Icons.chat, size: 28),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 28),
              label: "",
            ),
          ],
        ),
        Positioned(
          top: -30,
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset("lib/assets/images/peeviewrevise.png", height: 74),
            ),
          ),
        ),
      ],
    );
  }
}
