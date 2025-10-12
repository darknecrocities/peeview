import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 for hiding system UI
import '../login/login_screen.dart';

class GuideStart extends StatefulWidget {
  const GuideStart({super.key});

  @override
  State<GuideStart> createState() => _GuideStartState();
}

class _GuideStartState extends State<GuideStart> {
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "lib/assets/images/easyhometest.png",
      "text":
      "Get instant urine analysis results from the comfort of your home with just your smartphone."
    },
    {
      "image": "lib/assets/images/aipowered.png",
      "text":
      "Advanced technology interprets your test results and provides clear, actionable health insights"
    },
    {
      "image": "lib/assets/images/connect.png",
      "text":
      "Find nearby clinics and healthcare providers when you need professional follow-up care"
    },
  ];

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // 👇 Hide system UI (immersive mode)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // 👇 Restore system UI when leaving this screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ White background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
          // ✅ AnimatedSwitcher for smooth fade effect on image
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Image.asset(
              _pages[_currentIndex]["image"]!,
              key: ValueKey<int>(_currentIndex), // important for switching
              height: 300,
            ),
          ),
          const SizedBox(height: 30),
          // ✅ AnimatedSwitcher for text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Padding(
              key: ValueKey<int>(_currentIndex), // change triggers fade
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _pages[_currentIndex]["text"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              bottom: 50.0, // 👈 lift button above navigation area
            ),
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _currentIndex == _pages.length - 1 ? "Get Started" : "Next",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
