import 'package:flutter/material.dart';

class CustomizeAppBarScreen extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  const CustomizeAppBarScreen({
    super.key,
    required this.onNotificationsTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // ✅ removes back button
      backgroundColor: const Color(0xFF0062C8),
      elevation: 0,
      title: const Text(
        "peeView",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: onNotificationsTap,
        ),
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: onProfileTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
