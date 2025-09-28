import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'clinic_search_map.dart'; // 👈 make sure this imports your ClinicMapScreen

class ClinicScreen extends StatefulWidget {
  const ClinicScreen({Key? key}) : super(key: key);

  @override
  State<ClinicScreen> createState() => _ClinicScreenState();
}

class _ClinicScreenState extends State<ClinicScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LocationData? _currentLocation;
  final Location _location = Location();

  // List of clinics
  final List<Map<String, dynamic>> clinics = [
    {
      "name": "HealthPlus Clinic",
      "address":
      "123 Health Avenue, Barangay Commonwealth, Quezon City, Metro Manila, 1100, Philippines",
      "lat": 14.6760,
      "lng": 121.0437,
      "open": true
    },
    {
      "name": "VitalCare Medical Center",
      "address":
      "456 Vital Street, Barangay Bel-Air, Makati City, Metro Manila, 1209, Philippines",
      "lat": 14.5547,
      "lng": 121.0244,
      "open": true
    },
    {
      "name": "Clearview Health Clinic",
      "address":
      "789 Clearview Road, Barangay Fort Bonifacio, Taguig City, Metro Manila, 1634, Philippines",
      "lat": 14.5216,
      "lng": 121.0509,
      "open": false
    },
    {
      "name": "MediCare Wellness Center",
      "address":
      "101 Wellness Blvd, Barangay Lahug, Cebu City, Cebu, 6000, Philippines",
      "lat": 10.3157,
      "lng": 123.8854,
      "open": true
    },
    {
      "name": "LifeCare Medical Clinic",
      "address":
      "222 LifeCare Ave, Barangay Agdao, Davao City, Davao del Sur, 8000, Philippines",
      "lat": 7.1907,
      "lng": 125.4553,
      "open": true
    },
    {
      "name": "Summit Medical Clinic",
      "address":
      "333 Summit St, Barangay 2, Bacolod City, Negros Occidental, 6100, Philippines",
      "lat": 10.6767,
      "lng": 122.9563,
      "open": false
    },
  ];

  Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedClinic;

  @override
  void initState() {
    super.initState();
    _setInitialMarker();
  }

  void _setInitialMarker() {
    setState(() {
      _markers = clinics.map((clinic) {
        return Marker(
          markerId: MarkerId(clinic["name"]),
          position: LatLng(clinic["lat"], clinic["lng"]),
          infoWindow:
          InfoWindow(title: clinic["name"], snippet: clinic["address"]),
          onTap: () {
            setState(() {
              _selectedClinic = clinic;
            });
          },
        );
      }).toSet();
    });
  }

  Future<void> _getCurrentLocation() async {
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

    _currentLocation = await _location.getLocation();
    if (_currentLocation != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLng(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      ));
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: LatLng(
                _currentLocation!.latitude!, _currentLocation!.longitude!),
            infoWindow: const InfoWindow(title: "You are here"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
          ),
        );
        _selectedClinic = {
          "name": "My Location",
          "address": "Your current location",
          "lat": _currentLocation!.latitude!,
          "lng": _currentLocation!.longitude!,
          "open": true
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show first 5 clinics to avoid lag
    final displayedClinics = clinics.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(14.5995, 120.9842), // Manila default
              zoom: 6,
            ),
            myLocationEnabled: true,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          // Search Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.blue),
                  hintText: "Search clinic in...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Use My Location Button
          Positioned(
            top: 110,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: _getCurrentLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.my_location, color: Colors.black),
                    SizedBox(width: 10),
                    Text("Use my current location"),
                  ],
                ),
              ),
            ),
          ),

          // Popular Clinics List
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(15),
              color: Colors.white.withOpacity(0.95),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Popular clinics",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Column(
                    children: displayedClinics.map((clinic) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClinicSearchMap(
                                clinics: clinics,            // pass full list
                                selectedClinic: clinic,      // pass the one tapped
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(clinic["name"],
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 3),
                                    Text(clinic["address"],
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.location_on, color: Colors.black),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Selected Clinic Card
          if (_selectedClinic != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.blue, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selectedClinic!["name"],
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text(_selectedClinic!["address"],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          Text(
                              _selectedClinic!["open"] ? "Open" : "Closed",
                              style: TextStyle(
                                  color: _selectedClinic!["open"]
                                      ? Colors.green
                                      : Colors.red)),
                        ],
                      ),
                    ),
                    const Text("2.5 km",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
