import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peeview/widgets/appbar/customize_app_bar_dash.dart';
import '../../widgets/navbar/customize_navbar.dart';
import 'package:peeview/screens/exclusive%20widgets/customize_appbar_screen.dart';
import 'package:peeview/screens/dashboard_screen.dart';
import 'package:peeview/screens/appointment/appointment_screen.dart';
import 'package:peeview/screens/profile/profile_screen.dart';
import 'package:flutter/services.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  final List<Map<String, String>> messages = [
    {
      "name": "Dr. Antonio Dela Cruz, MD",
      "message": "Your test shows signs of dehydration.",
      "time": "10:08 PM",
      "image": "https://randomuser.me/api/portraits/men/32.jpg",
    },
    {
      "name": "MedCare Wellness Clinic",
      "message": "Thank you for choosing MedCare Wellness Clinic!",
      "time": "09:24 AM",
      "image": "https://cdn-icons-png.flaticon.com/512/2966/2966327.png",
    },
    {
      "name": "Dr. Rafael Moreno, MD",
      "message": "Your test results show possible signs of UTI.",
      "time": "08:57 AM",
      "image": "https://randomuser.me/api/portraits/men/85.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomizeAppBarDash(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                screenWidth * 0.04, screenHeight * 0.015, screenWidth * 0.04, screenHeight * 0.01),
            child: Center(
              child: Text(
                "Messages",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.06),
                topRight: Radius.circular(screenWidth * 0.06),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF0062C8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.06),
                  topRight: Radius.circular(screenWidth * 0.06),
                ),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              tabs: const [
                Expanded(child: Center(child: Text("All"))),
                Expanded(child: Center(child: Text("Doctors"))),
                Expanded(child: Center(child: Text("Clinic"))),
              ].map((widget) => Tab(child: widget)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMessageList(messages, screenWidth),
                _buildMessageList(
                  messages.where((m) => m["name"]!.contains("Dr.")).toList(),
                  screenWidth,
                ),
                _buildMessageList(
                  messages.where((m) => m["name"]!.contains("Clinic")).toList(),
                  screenWidth,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF0062C8),
        child: Icon(Icons.chat, color: Colors.white, size: screenWidth * 0.07),
        onPressed: () => debugPrint("New message tapped"),
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const DashboardScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AppointmentScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const ProfileScreen(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMessageList(List<Map<String, String>> msgs, double screenWidth) {
    return ListView.separated(
      itemCount: msgs.length,
      separatorBuilder: (_, __) => Divider(height: screenWidth * 0.01),
      itemBuilder: (context, index) {
        final msg = msgs[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(msg["image"]!),
            radius: screenWidth * 0.06,
          ),
          title: Text(
            msg["name"]!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.04,
            ),
          ),
          subtitle: Text(
            msg["message"]!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: screenWidth * 0.035),
          ),
          trailing: Text(
            msg["time"]!,
            style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.03),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  doctorName: msg["name"]!,
                  doctorImage: msg["image"]!,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String doctorName;
  final String doctorImage;

  const ChatScreen({
    super.key,
    required this.doctorName,
    required this.doctorImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "sender": "doctor",
      "text":
      "Hello Graciella, your test shows signs of dehydration. Please drink more water daily, about 8 glasses.",
      "time": "10:08 PM",
    },
    {
      "sender": "user",
      "text": "I’ve been tired and thirsty lately. Could that be why?",
      "time": "10:09 PM",
    },
    {
      "sender": "doctor",
      "text":
      "Yes, those are common symptoms of dehydration. Try increasing water intake. If you still feel unwell, let me know.",
      "time": "10:10 PM",
    },
  ];
  bool _isTyping = false;

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;
    setState(() {
      _messages.add({"sender": "user", "text": text, "time": "Now"});
      _isTyping = true;
    });
    _controller.clear();

    final reply = await _fetchGeminiResponse(text);

    setState(() {
      _messages.add({"sender": "doctor", "text": reply, "time": "Now"});
      _isTyping = false;
    });
  }

  Future<String> _fetchGeminiResponse(String prompt) async {
    const apiKey = "AIzaSyCYpADok1bJHn6dy5RHPcb_HaPL1ld3mmM";
    const url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
          "Sorry, I couldn’t understand that.";
    } else {
      return "Error: ${response.body}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
                backgroundImage: NetworkImage(widget.doctorImage),
                radius: screenWidth * 0.07),
            SizedBox(width: screenWidth * 0.02),
            Expanded(
              child: Text(
                widget.doctorName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Icon(Icons.video_call, color: Colors.black54, size: screenWidth * 0.07),
          SizedBox(width: screenWidth * 0.02),
          Icon(Icons.call, color: Colors.black54, size: screenWidth * 0.07),
          SizedBox(width: screenWidth * 0.02),
          Icon(Icons.more_vert, color: Colors.black54, size: screenWidth * 0.07),
          SizedBox(width: screenWidth * 0.02),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(screenWidth * 0.04),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["sender"] == "user";
                return Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.035,
                        vertical: screenHeight * 0.012,
                      ),
                      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF0062C8)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      ),
                      child: Text(
                        msg["text"]!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: screenWidth * 0.038,
                          height: 1.4,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.005),
                      child: Text(
                        msg["time"]!,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.03,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Dr. is typing...",
                  style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035),
                ),
              ),
            ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: const Color(0xFF0062C8), size: screenWidth * 0.07),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
