// lib/loading_screen.dart

import 'package:flutter/material.dart';
import 'guide_start.dart'; // ⬅️ go to GuideStart instead of HomePage

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToGuide();
  }

  Future<void> _navigateToGuide() async {
    await Future.delayed(const Duration(seconds: 2)); // fake loading
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GuideStart()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0062C8),
      body: Center(
        child: Text(
          'peeView',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
            fontSize: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
