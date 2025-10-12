import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:peeview/widgets/navbar/customize_navbar.dart';
import '../exclusive widgets/customize_appbar_screen.dart';
import 'upload_result_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedFile;
  bool _uploading = false;
  int _selectedIndex = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomizeAppBarScreen(
        onNotificationsTap: () => debugPrint("Notifications tapped"),
        onProfileTap: () => debugPrint("Profile tapped"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              const Text(
                "Upload your lab report as an image or PDF for instant analysis.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _CheckItem(text: "Supports JPG, PNG, and PDF files"),
                  SizedBox(height: 12),
                  _CheckItem(text: "Upload takes less than a minute"),
                  SizedBox(height: 12),
                  _CheckItem(text: "AI analysis when complete"),
                ],
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "What you’ll need:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "• Lab report\n• Stable internet connection",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF0066E6),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _selectedFile == null
                          ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 50,
                            color: Color(0xFF0066E6),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Drag & drop to upload\nor browse",
                            style: TextStyle(
                              color: Color(0xFF0066E6),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                          : Text(
                        "Selected: ${_selectedFile?.path
                            .split('/')
                            .last ?? 'Unknown'}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                  (_uploading || _selectedFile == null) ? null : _uploadFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066E6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: _uploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Upload",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "By uploading, you agree to use this feature responsibly to keep peeView safe and helpful for everyone.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          debugPrint("Selected Nav Index: $_selectedIndex");
        },
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) {
        setState(() {
          _selectedFile = File(path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selected file path is null.")),
        );
      }
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() => _uploading = true);

    // Capture local reference
    final fileToUpload = _selectedFile;

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must be logged in to upload.")),
        );
        return;
      }

      // Save file reference in Firestore
      await _firestore.collection("uploaded_reports").add({
        "userId": currentUser.uid,
        "fileName": fileToUpload?.path
            .split('/')
            .last ?? 'unknown',
        "uploadedAt": FieldValue.serverTimestamp(),
      });

      // Navigate safely
      if (fileToUpload != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UploadResultScreen(file: fileToUpload),
          ),
        );
      }

      setState(() => _selectedFile = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading file: $e")),
      );
    } finally {
      setState(() => _uploading = false);
    }
  }
}

  class _CheckItem extends StatelessWidget {
  final String text;
  const _CheckItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_box, color: Color(0xFF33B5FF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
