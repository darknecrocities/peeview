import 'package:flutter/material.dart';
import 'package:peeview/screens/profile/profile_screen.dart';

class CustomizeAppBarDash extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomizeAppBarDash({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actionsPadding: EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: const Color(0xFF0062C8),
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: const Text(
        "peeView",
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: Colors.white),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
        ),
      ],
    );
  }
}
