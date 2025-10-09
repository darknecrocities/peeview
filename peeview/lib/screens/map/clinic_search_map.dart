// clinic_search_map.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'doctors_screen.dart';

class ClinicSearchMap extends StatefulWidget {
  const ClinicSearchMap({Key? key}) : super(key: key);

  @override
  State<ClinicSearchMap> createState() => _ClinicSearchMapState();
}

class _ClinicSearchMapState extends State<ClinicSearchMap> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();

  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  bool _loading = false;

  static const String apiKey = "AIzaSyDE--Gb6spVlLkqlylj3vPBphoKM9aqllI"; // 🔑 Replace with your valid key

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /// ✅ Get user location and search nearby clinics within 20 km
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      final loc = await _location.getLocation();
      if (loc.latitude == null || loc.longitude == null) return;

      _currentLocation = loc;

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(loc.latitude!, loc.longitude!),
          13,
        ),
      );

      await _searchNearbyHospitals(loc.latitude!, loc.longitude!);
      _addCurrentLocationMarker();
    } catch (e) {
      debugPrint("❌ Error getting location: $e");
    }
  }

  /// ✅ Add user marker
  void _addCurrentLocationMarker() {
    if (_currentLocation == null) return;

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("currentLocation"),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: const InfoWindow(title: "📍 You are here"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });
  }

  /// ✅ Search nearby clinics using Google Places API (radius: 20 km)
  Future<void> _searchNearbyHospitals(double lat, double lng) async {
    setState(() => _loading = true);

    const double searchRadius = 20000; // 20 km radius
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
          "?location=$lat,$lng"
          "&radius=$searchRadius"
          "&type=hospital"
          "&keyword=clinic|medical|health"
          "&key=$apiKey",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        debugPrint("Google API error: ${response.statusCode}");
        return;
      }

      final data = jsonDecode(response.body);
      final results = (data["results"] as List).map((place) {
        return {
          "name": place["name"] ?? "Unknown Clinic",
          "address": place["vicinity"] ?? "No address available",
          "lat": place["geometry"]["location"]["lat"],
          "lng": place["geometry"]["location"]["lng"],
          "status": place["business_status"] ?? "Open",
        };
      }).toList();

      if (results.isEmpty) {
        debugPrint("⚠️ No nearby clinics found");
      }

      final markers = results.map((clinic) {
        return Marker(
          markerId: MarkerId(clinic["name"]),
          position: LatLng(clinic["lat"], clinic["lng"]),
          infoWindow: InfoWindow(
            title: clinic["name"],
            snippet: clinic["address"],
          ),
          onTap: () => _showClinicCard(clinic),
        );
      }).toSet();

      setState(() {
        _markers = {..._markers, ...markers};
      });
    } catch (e) {
      debugPrint("❌ Error fetching nearby clinics: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showClinicCard(Map<String, dynamic> clinic) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(clinic["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(clinic["address"]),
            const SizedBox(height: 5),
            Text(
              clinic["status"],
              style: TextStyle(
                color: (clinic["status"] ?? "").toString().toLowerCase() == "open"
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text("Book Now"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(14.5995, 120.9842), // Default: Manila
              zoom: 6,
            ),
            myLocationEnabled: true,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) _controller.complete(controller);
            },
          ),

          // 📍 Floating location button
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.blueAccent,
              icon: const Icon(Icons.my_location),
              label: const Text("Use My Location"),
              onPressed: _getCurrentLocation,
            ),
          ),

          if (_loading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
