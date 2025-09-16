import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/customize_navbar.dart';
import '../widgets/customize_appbar.dart';
import '../widgets/dashboard_categories.dart';
import '../widgets/dashboard_offers.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // ✅ Hide BOTH status bar and navigation bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [], // explicitly removes all overlays
    );
  }

  @override
  void dispose() {
    // ✅ Restore system UI when leaving this screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        debugPrint("Home tapped");
        break;
      case 1:
        debugPrint("Calendar tapped");
        break;
      case 2:
        debugPrint("History tapped");
        break;
      case 3:
        debugPrint("Settings tapped");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? "User";

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, // 🔹 make content go behind system bars
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomizeAppBar(
            userName: userName,
            onNotificationsTap: () => debugPrint("Notifications tapped"),
            onProfileTap: () => debugPrint("Profile tapped"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search results, doctors...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00247D)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00247D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00247D)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "EXPLORE CATEGORIES",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const DashboardCategories(),
          const SizedBox(height: 16),
          const DashboardOffers(),
        ],
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
