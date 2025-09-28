import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

import '../widgets/customize_navbar.dart';
import 'customize_appbar_screen.dart';

class ScanUploadScreen extends StatefulWidget {
  const ScanUploadScreen({super.key});

  @override
  State<ScanUploadScreen> createState() => _ScanUploadScreenState();
}

class _ScanUploadScreenState extends State<ScanUploadScreen>
    with SingleTickerProviderStateMixin {
  // Camera
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;

  // UI state
  bool _isFlashOn = false;
  bool _showGrid = true;
  bool _scanning = false;
  XFile? _capturedImage;
  String _recognizedText = "";

  // Scan animation
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  // Crop rectangle (percentages)
  Rect cropRect = const Rect.fromLTWH(0.1, 0.2, 0.8, 0.6);

  // Constants
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

  Future<void> _captureAndProcess() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    final image = await _cameraController!.takePicture();
    _capturedImage = image;
    setState(() {});
    await _cropAndRecognize(File(image.path));
  }

  Future<void> _pickAndProcess() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _capturedImage = picked;
      setState(() {});
      await _cropAndRecognize(File(picked.path));
    }
  }

  Future<void> _cropAndRecognize(File file) async {
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return;

    final crop = Rect.fromLTWH(
      cropRect.left * image.width,
      cropRect.top * image.height,
      cropRect.width * image.width,
      cropRect.height * image.height,
    );

    final cropped = img.copyCrop(image, x: crop.left.toInt(), y: crop.top.toInt(), width: crop.width.toInt(), height: crop.height.toInt());
    final tempFile = File('${Directory.systemTemp.path}/cropped.png')
      ..writeAsBytesSync(img.encodePng(cropped));

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(InputImage.fromFile(tempFile));
    await textRecognizer.close();

    setState(() {
      _recognizedText = recognizedText.text;
      _capturedImage = XFile(tempFile.path);
    });

    if (_recognizedText.isNotEmpty) _showRecognizedText(_recognizedText);
  }

  Future<void> _showRecognizedText(String text) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Recognized Text", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SingleChildScrollView(child: Text(text, style: const TextStyle(fontSize: 16))),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
                ),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFlash() {
    if (_cameraController == null) return;
    _isFlashOn = !_isFlashOn;
    _cameraController!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  void _toggleScanAnimation() {
    _scanning = !_scanning;
    _scanning ? _scanController.repeat() : _scanController.stop();
    setState(() {});
  }

  Widget _topRow() {
    final actions = [
      {'icon': _isFlashOn ? Icons.flash_on : Icons.flash_off, 'onTap': _toggleFlash, 'color': Colors.yellowAccent},
      {'icon': Icons.grid_on, 'onTap': () => setState(() => _showGrid = !_showGrid), 'color': Colors.white},
      {'icon': Icons.document_scanner, 'onTap': _toggleScanAnimation, 'color': Colors.white},
      {'icon': Icons.auto_awesome, 'onTap': () {}, 'color': Colors.white},
    ];
    return _actionRow(actions);
  }

  Widget _bottomRow() {
    final actions = [
      {'icon': null, 'label': 'Cancel', 'onTap': () {}},
      {'icon': Icons.refresh, 'onTap': () => setState(() { _capturedImage = null; _recognizedText = ""; })},
      {'icon': null, 'isCapture': true, 'onTap': _captureAndProcess},
      {'icon': Icons.photo_library, 'onTap': _pickAndProcess},
      {'icon': null, 'label': 'Done', 'onTap': () {}},
    ];
    return _actionRow(actions, isBottom: true);
  }

  Widget _actionRow(List<Map<String, dynamic>> actions, {bool isBottom = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(buttonRadius)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) {
          if (a['isCapture'] == true) {
            return GestureDetector(
              onTap: a['onTap'],
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
            return IconButton(icon: Icon(a['icon'], color: a['color'] ?? Colors.white), onPressed: a['onTap']);
          } else {
            return TextButton(onPressed: a['onTap'], child: Text(a['label'], style: const TextStyle(color: Colors.white)));
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
                  ? (_cameraController != null && _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : const Center(child: CircularProgressIndicator()))
                  : Image.file(File(_capturedImage!.path), fit: BoxFit.cover),

              // Crop Grid
              if (_showGrid)
                Positioned(
                  left: cropRect.left * previewWidth,
                  top: cropRect.top * previewHeight,
                  width: cropRect.width * previewWidth,
                  height: cropRect.height * previewHeight,
                  child: CustomPaint(painter: CropOverlayPainter(cropRect: Rect.fromLTWH(0, 0, 1, 1))),
                ),

              // Scan Animation
              if (_scanning)
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    final top = cropRect.top * previewHeight + _scanAnimation.value * cropRect.height * previewHeight;
                    return Positioned(
                      left: cropRect.left * previewWidth,
                      top: top,
                      width: cropRect.width * previewWidth,
                      height: scanLineHeight,
                      child: Container(color: Colors.redAccent.withOpacity(0.8)),
                    );
                  },
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
          if (_recognizedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Recognized Text:\n$_recognizedText", style: const TextStyle(fontSize: 16)),
            ),
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
    canvas.drawRect(Rect.fromLTWH(
      cropRect.left * size.width,
      cropRect.top * size.height,
      cropRect.width * size.width,
      cropRect.height * size.height,
    ), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
