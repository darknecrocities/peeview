import 'package:flutter/material.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/appointment/appointment_screen.dart';
import '../../screens/chat/message_screen.dart';

class CustomizeNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomizeNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // Helper to push with fade animation
  void _navigateWithFade(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

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
            switch (index) {
              case 0:
                _navigateWithFade(context, const DashboardScreen());
                break;
              case 1:
                _navigateWithFade(context, const AppointmentScreen());
                break;
              case 3:
                _navigateWithFade(context, const MessageScreen());
                break;
              case 4:
                _navigateWithFade(context, const ProfileScreen());
                break;
              case 2:
              // Center logo, do nothing
                break;
              default:
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
            BottomNavigationBarItem(
              icon: SizedBox.shrink(),
              label: "",
            ),
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

        // Floating PeeView Logo
        Positioned(
          top: -30,
          child: GestureDetector(
            onTap: () {
              debugPrint("PeeView logo tapped!");
            },
            child: Image.asset(
              "lib/assets/images/peeviewrevise.png",
              fit: BoxFit.cover,
              height: 74,
              width: 74,
            ),
          ),
        ),
      ],
    );
  }
}
