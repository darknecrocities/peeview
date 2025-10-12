import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/widgets/customize_navbar.dart';
import 'package:peeview/screens/customize_appbar_screen.dart';
import 'package:peeview/screens/dashboard_screen.dart';
import 'package:peeview/screens/appointment/appointment_screen.dart';
import 'package:peeview/screens/profile_screen.dart';
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

    // 🔹 Initialize TabController
    _tabController = TabController(length: 3, vsync: this);

    // 🔹 Hide Android navbar & status bar
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomizeAppBarScreen(
          onNotificationsTap: () => debugPrint("Notifications tapped"),
          onProfileTap: () => debugPrint("Profile tapped"),
        ),
      ),
      body: Column(
        children: [
          // 🔹 Header with "Message" and Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Message",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.search, size: 24),
              ],
            ),
          ),
          // 🔹 Tabs (All, Doctors, Clinic)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF0062C8),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: const [
                Tab(text: "All"),
                Tab(text: "Doctors"),
                Tab(text: "Clinic"),
              ],
            ),
          ),
          // 🔹 Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMessageList(messages),
                _buildMessageList(
                  messages.where((m) => m["name"]!.contains("Dr.")).toList(),
                ),
                _buildMessageList(
                  messages.where((m) => m["name"]!.contains("Clinic")).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      // 🔹 Floating new message button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0062C8),
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () => debugPrint("New message tapped"),
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: 3, // ✅ Chat tab is active
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

  Widget _buildMessageList(List<Map<String, String>> msgs) {
    return ListView.separated(
      itemCount: msgs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final msg = msgs[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(msg["image"]!),
            radius: 24,
          ),
          title: Text(
            msg["name"]!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            msg["message"]!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            msg["time"]!,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
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

// 🔹 Chat Screen
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
      "time": "10:08 PM"
    },
    {
      "sender": "user",
      "text": "I’ve been tired and thirsty lately. Could that be why?",
      "time": "10:09 PM"
    },
    {
      "sender": "doctor",
      "text":
      "Yes, those are common symptoms of dehydration. Try increasing water intake. If you still feel unwell, let me know.",
      "time": "10:10 PM"
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
              {"text": prompt}
            ]
          }
        ]
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
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.doctorName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // ✅ prevents overflow
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.video_call, color: Colors.black54),
          SizedBox(width: 12),
          Icon(Icons.call, color: Colors.black54),
          SizedBox(width: 12),
          Icon(Icons.more_vert, color: Colors.black54),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["sender"] == "user";
                return Column(
                  crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF0062C8)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg["text"]!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        msg["time"]!,
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Dr. is typing...",
                    style: TextStyle(color: Colors.grey)),
              ),
            ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF0062C8)),
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
