import 'package:flutter/material.dart';

class CustomizeAppBar extends StatelessWidget {
  final String userName;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  const CustomizeAppBar({
    super.key,
    required this.userName,
    required this.onNotificationsTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Welcome text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome,",
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 30, // 🔹 Increased font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Icons
            Row(
              children: [
                IconButton(
                  onPressed: onNotificationsTap,
                  icon: const Icon(Icons.notifications,
                      color: Color(0xFF00247D)),
                ),
                IconButton(
                  onPressed: onProfileTap,
                  icon: const Icon(Icons.person, color: Color(0xFF00247D)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
