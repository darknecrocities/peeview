import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart'; // ✅ Import DashboardScreen

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
              // ✅ Navigate to Dashboard when Home tapped
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            } else {
              onTap(index); // keep the same behavior for others
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
              icon: Icon(Icons.history, size: 28),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 28),
              label: "",
            ),
          ],
        ),

        // Floating PeeView Logo (center button)
        Positioned(
          top: -30,
          child: GestureDetector(
            onTap: () {
              // TODO: Add action for PeeView logo button
              debugPrint("PeeView logo tapped!");
            },
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  "lib/assets/images/peeview_logo_nobg.png",
                  height: 42,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
