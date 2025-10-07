// lib/screens/scan_upload_screen.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

import '../../widgets/customize_navbar.dart';
import '../customize_appbar_screen.dart';
import 'scan_result.dart';

class ScanUploadScreen extends StatefulWidget {
  const ScanUploadScreen({super.key});

  @override
  State<ScanUploadScreen> createState() => _ScanUploadScreenState();
}

class _ScanUploadScreenState extends State<ScanUploadScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;

  bool _isFlashOn = false;
  bool _showGrid = true;
  bool _scanning = false;
  bool _isProcessing = false; // new: to prevent double processing
  XFile? _capturedImage;

  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  Rect cropRect = const Rect.fromLTWH(0.1, 0.2, 0.8, 0.6);

  final Color primaryColor = const Color(0xFF1E63D0);
  final double buttonRadius = 16.0;
  final double scanLineHeight = 3.0;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_scanController);
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _cameraController!.initialize();
    await _initializeControllerFuture;
    if (mounted) {
      setState(() {
        _scanning = true;
        _scanController.repeat();
      });
    }
  }

  // Capture only sets the preview image now (no immediate OCR)
  Future<void> _captureAndProcess() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final image = await _cameraController!.takePicture();
      _capturedImage = image;
      setState(() {});
    } catch (e) {
      debugPrint('Capture error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to capture image')));
    }
  }

  // Pick only sets the preview image now (no immediate OCR)
  Future<void> _pickAndProcess() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        _capturedImage = picked;
        setState(() {});
      }
    } catch (e) {
      debugPrint('Pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
    }
  }

  // This will crop the captured image, run OCR, then send to Gemini.
  Future<void> _cropAndRecognize(File file) async {
    // decode image bytes
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Unable to decode image');
    }

    // compute crop rectangle in pixels
    final crop = Rect.fromLTWH(
      (cropRect.left * image.width).clamp(0, image.width.toDouble()),
      (cropRect.top * image.height).clamp(0, image.height.toDouble()),
      (cropRect.width * image.width).clamp(1, image.width.toDouble()),
      (cropRect.height * image.height).clamp(1, image.height.toDouble()),
    );

    // ensure integer bounds & inside image
    final x = crop.left.toInt().clamp(0, image.width - 1);
    final y = crop.top.toInt().clamp(0, image.height - 1);
    final w = crop.width.toInt().clamp(1, image.width - x);
    final h = crop.height.toInt().clamp(1, image.height - y);

    final cropped = img.copyCrop(image, x: x, y: y, width: w, height: h);

    final tempFile = File('${Directory.systemTemp.path}/peeview_cropped.png')
      ..writeAsBytesSync(img.encodePng(cropped));

    // Use InputImage.fromFilePath which is compatible with google_mlkit package
    final inputImage = InputImage.fromFilePath(tempFile.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognized = await textRecognizer.processImage(inputImage);
      final ocrText = recognized.text.trim();
      if (ocrText.isEmpty) {
        throw Exception('No text detected. Try a clearer image or different crop.');
      }
      await _sendToGemini(ocrText);
    } finally {
      await textRecognizer.close();
    }
  }

  Future<void> _sendToGemini(String ocrText) async {
    const apiKey = "APIKEY";
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
    );

    // 🧠 AI prompt: 80-word insight + numeric probability
    final prompt = """
You are an AI medical assistant analyzing urinalysis results.

Below is the OCR text from a patient's urine test:

\"\"\"$ocrText\"\"\"

Tasks:
1. Estimate the likelihood (0–100%) that the patient has Chronic Kidney Disease (CKD).
2. Provide an approximately 80-word medical interpretation of the urinalysis findings.
3. End your response with this exact format:
CKD Probability: [number]%

Keep your response plain text. Do not use JSON, bullet points, or markdown.
""";

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      // 📡 Send request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      // 🧩 Close loading dialog if any
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String aiText = "";
        try {
          aiText = data["candidates"][0]["content"]["parts"][0]["text"] ?? "";
        } catch (_) {
          aiText = "No insights generated. Please retry with a clearer image.";
        }

        // 🔍 Extract probability value from Gemini response
        final regex = RegExp(r'CKD Probability:\s*(\d+)%');
        int ckdProbability = 0;
        final match = regex.firstMatch(aiText);
        if (match != null) {
          ckdProbability = int.tryParse(match.group(1) ?? "0") ?? 0;
        }

        // 🎯 Compute other fields
        int nonCkdProbability = (100 - ckdProbability).clamp(0, 100);
        String status;
        if (ckdProbability >= 70) {
          status = "HIGH";
        } else if (ckdProbability >= 40) {
          status = "MODERATE";
        } else {
          status = "LOW";
        }

        // 🧭 Navigate to results page
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanResultScreen(results: {
              "aiInsights": aiText,
              "suggestedAction":
              "Consult a healthcare professional for further advice.",
              "diseasePrediction": {
                "ckdProbability": ckdProbability,
                "nonCkdProbability": nonCkdProbability,
              },
              "status": status,
            }),
          ),
        );
      } else {
        debugPrint("Gemini API HTTP ${response.statusCode}: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gemini API error (${response.statusCode}). Try again.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Gemini/network error: $e');
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to communicate with AI service: $e')),
      );
    }
  }



  void _toggleFlash() {
    if (_cameraController == null) return;
    _isFlashOn = !_isFlashOn;
    _cameraController!
        .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  void _toggleScanAnimation() {
    _scanning = !_scanning;
    _scanning ? _scanController.repeat() : _scanController.stop();
    setState(() {});
  }

  // Pressing Done will trigger OCR and AI analysis.
  Future<void> _onDonePressed() async {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please capture or pick an image first")),
      );
      return;
    }
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    // show non-dismissible progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _cropAndRecognize(File(_capturedImage!.path));
    } catch (e) {
      // close dialog if still open
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _topRow() {
    final actions = [
      {
        'icon': _isFlashOn ? Icons.flash_on : Icons.flash_off,
        'onTap': _toggleFlash,
        'color': Colors.yellowAccent
      },
      {
        'icon': Icons.grid_on,
        'onTap': () => setState(() => _showGrid = !_showGrid),
        'color': Colors.white
      },
      {'icon': Icons.document_scanner, 'onTap': _toggleScanAnimation, 'color': Colors.white},
    ];
    return _actionRow(actions);
  }

  Widget _bottomRow() {
    final actions = [
      {'icon': null, 'label': 'Cancel', 'onTap': () => Navigator.pop(context)},
      {
        'icon': Icons.refresh,
        'onTap': () => setState(() {
          _capturedImage = null;
        })
      },
      {'icon': null, 'isCapture': true, 'onTap': _captureAndProcess},
      {'icon': Icons.photo_library, 'onTap': _pickAndProcess},
      {
        'icon': null,
        'label': 'Done',
        'onTap': _onDonePressed,
      },
    ];
    return _actionRow(actions, isBottom: true);
  }

  Widget _actionRow(List<Map<String, dynamic>> actions, {bool isBottom = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: primaryColor, borderRadius: BorderRadius.circular(buttonRadius)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) {
          if (a['isCapture'] == true) {
            return GestureDetector(
              onTap: a['onTap'] as void Function()?,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2),
                ),
              ),
            );
          } else if (a['icon'] != null) {
            return IconButton(
                icon: Icon(a['icon'], color: a['color'] ?? Colors.white),
                onPressed: a['onTap'] as void Function()?);
          } else {
            return TextButton(
                onPressed: a['onTap'] as void Function()?,
                child: Text(a['label'],
                    style: const TextStyle(color: Colors.white)));
          }
        }).toList(),
      ),
    );
  }

  Widget _cameraPreview() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final previewWidth = constraints.maxWidth;
          final previewHeight = constraints.maxHeight;

          return Stack(
            children: [
              _capturedImage == null
                  ? (_cameraController != null &&
                  _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : const Center(child: CircularProgressIndicator()))
                  : Image.file(File(_capturedImage!.path), fit: BoxFit.cover),

              if (_showGrid)
                Positioned(
                  left: cropRect.left * previewWidth,
                  top: cropRect.top * previewHeight,
                  width: cropRect.width * previewWidth,
                  height: cropRect.height * previewHeight,
                  child: CustomPaint(
                      painter: CropOverlayPainter(
                          cropRect: Rect.fromLTWH(0, 0, 1, 1))),
                ),

              if (_scanning)
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    final top = cropRect.top * previewHeight +
                        _scanAnimation.value * cropRect.height * previewHeight;
                    return Positioned(
                      left: cropRect.left * previewWidth,
                      top: top,
                      width: cropRect.width * previewWidth,
                      height: scanLineHeight,
                      child: Container(color: Colors.redAccent.withOpacity(0.8)),
                    );
                  },
                ),

              // optional overlay while processing (in addition to dialog)
              if (_isProcessing)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color.fromARGB(60, 0, 0, 0),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomizeAppBarScreen(onNotificationsTap: () {}, onProfileTap: () {}),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _topRow(),
          const SizedBox(height: 12),
          _cameraPreview(),
          const SizedBox(height: 12),
          _bottomRow(),
        ],
      ),
      bottomNavigationBar: CustomizeNavBar(currentIndex: 0, onTap: (index) {}),
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  CropOverlayPainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
        Rect.fromLTWH(
          cropRect.left * size.width,
          cropRect.top * size.height,
          cropRect.width * size.width,
          cropRect.height * size.height,
        ),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
