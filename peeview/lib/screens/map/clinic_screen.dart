import 'dart:async';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'doctors_screen.dart';

class ClinicScreen extends StatefulWidget {
  const ClinicScreen({Key? key}) : super(key: key);

  @override
  State<ClinicScreen> createState() => _ClinicScreenState();
}

class _ClinicScreenState extends State<ClinicScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();

  LocationData? _currentLocation;
  bool _showNearbyClinics = false;
  bool _isLoading = false;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _nearbyFacilities = [];
  List<Map<String, dynamic>> _allFacilities = [];

  @override
  void initState() {
    super.initState();
    _loadInitialClinics(); // ✅ Load 10 facilities on start (before location)
  }

  /// Load CSV and show 10 healthcare facilities (no location yet)
  Future<void> _loadInitialClinics() async {
    setState(() => _isLoading = true);

    final rawData = await rootBundle.loadString('lib/data/philippines.csv');
    final List<List<dynamic>> csvData =
    const CsvToListConverter(eol: "\n").convert(rawData);

    if (csvData.isEmpty) return;

    final headers = csvData.first;
    final rows = csvData.skip(1).toList();

    List<Map<String, dynamic>> allFacilities = [];

    for (var row in rows) {
      final rowMap = Map.fromIterables(headers, row);

      final amenity = (rowMap['amenity'] ?? '').toString().toLowerCase();
      final healthcare = (rowMap['healthcare'] ?? '').toString().toLowerCase();

      if (!(amenity.contains('clinic') ||
          amenity.contains('hospital') ||
          amenity.contains('medical') ||
          amenity.contains('laboratory') ||
          healthcare.contains('clinic') ||
          healthcare.contains('hospital') ||
          healthcare.contains('medical') ||
          healthcare.contains('laboratory'))) continue;

      final double? fLat = double.tryParse(rowMap['Y']?.toString() ?? '');
      final double? fLng = double.tryParse(rowMap['X']?.toString() ?? '');
      if (fLat == null || fLng == null) continue;

      allFacilities.add({
        "name": rowMap['name'] ?? "Unnamed Facility",
        "address": rowMap['addr_street'] ?? "No address",
        "lat": fLat,
        "lng": fLng,
        "type": rowMap['amenity'] ?? rowMap['healthcare'] ?? "Unknown",
      });
    }

    _allFacilities = allFacilities;

    // ✅ Default view: Manila coordinates
    const centerLat = 14.5995;
    const centerLng = 120.9842;

    final randomFacilities = allFacilities.take(10).toList();
    _updateMarkers(randomFacilities);

    setState(() {
      _nearbyFacilities = randomFacilities;
      _showNearbyClinics = true;
      _isLoading = false;
    });

    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(const LatLng(centerLat, centerLng), 12),
    );
  }

  /// Use current location and filter nearby healthcare (within 30km)
  Future<void> _initLocation() async {
    setState(() {
      _isLoading = true;
      _showNearbyClinics = false; // 👈 hide list while loading
    });

    final serviceEnabled = await _location.serviceEnabled() ||
        await _location.requestService();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    var permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        setState(() => _isLoading = false);
        return;
      }
    }

    final loc = await _location.getLocation();
    if (loc.latitude == null || loc.longitude == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _currentLocation = loc);

    final controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(loc.latitude!, loc.longitude!),
      14,
    ));

    await _fetchNearbyClinics(
      lat: loc.latitude!,
      lng: loc.longitude!,
      radiusKm: 30,
    );

    // ✅ Show list again when done loading
    setState(() {
      _isLoading = false;
      _showNearbyClinics = false;
    });
  }

  Future<void> _fetchNearbyClinics({
    required double lat,
    required double lng,
    double radiusKm = 30, // this radius will only affect the list, not markers
  }) async {
    setState(() => _isLoading = true);

    List<Map<String, dynamic>> allWithDistance = [];

    // ✅ Compute distance for all facilities (no radius filter for map markers)
    for (var f in _allFacilities) {
      final distance = _calculateDistance(lat, lng, f["lat"], f["lng"]);
      allWithDistance.add({...f, "distance": distance});
    }

    // ✅ Sort by distance (nearest first)
    allWithDistance.sort((a, b) => a["distance"].compareTo(b["distance"]));

    // ✅ Pick only top 10 for the LIST
    final topResults = allWithDistance.take(10).toList();

    // ✅ But markers will show EVERYTHING (not just 10)
    _updateMarkers(allWithDistance);

    setState(() {
      _nearbyFacilities = topResults;
      _showNearbyClinics = true; // keep list visible if needed
      _isLoading = false;
    });
  }


  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth radius km
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  void _updateMarkers(List<Map<String, dynamic>> facilities) {
    final newMarkers = <Marker>{};

    for (var f in facilities) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(f["name"]),
          position: LatLng(f["lat"], f["lng"]),
          infoWindow: InfoWindow(
            title: f["name"],
            snippet: f["address"],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen),
          onTap: () => _showClinicCard(f),
        ),
      );
    }

    if (_currentLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId("currentLocation"),
          position: LatLng(
              _currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: const InfoWindow(title: "You are here"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure),
        ),
      );
    }

    setState(() => _markers = newMarkers);
  }

  void _showClinicCard(Map<String, dynamic> clinic) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            Text(
              clinic["name"],
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              clinic["address"],
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text("${clinic["type"]}"),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: const TextStyle(
                      fontSize: 12, color: Colors.blueAccent),
                ),
                const SizedBox(width: 10),
                if (clinic["distance"] != null)
                  Text(
                    "${clinic["distance"].toStringAsFixed(2)} km away",
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DoctorScreen()));
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text("Book Now"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
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
              target: LatLng(14.5995, 120.9842),
              zoom: 6,
            ),
            myLocationEnabled: true,
            markers: _markers,
            onMapCreated: (controller) {
              if (!_controller.isCompleted) _controller.complete(controller);
            },
          ),

          // 🔍 Search bar + Location button
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search nearby clinic...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.black54),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _nearbyFacilities = _allFacilities
                            .where((f) =>
                        f["name"]
                            .toString()
                            .toLowerCase()
                            .contains(value.toLowerCase()) ||
                            f["address"]
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .take(10)
                            .toList();
                        _updateMarkers(_nearbyFacilities);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Use my current location
                GestureDetector(
                  onTap: _initLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.my_location, color: Colors.black),
                        SizedBox(width: 10),
                        Text("Use my current location"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),

          if (_showNearbyClinics && !_isLoading)
            Positioned(
              top: 160,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.white.withOpacity(0.95),
                child: ListView.builder(
                  itemCount: _nearbyFacilities.length,
                  itemBuilder: (context, index) {
                    final facility = _nearbyFacilities[index];
                    return InkWell(
                      onTap: () => _showClinicCard(facility),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom:
                              BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    facility["name"],
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    facility["address"],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 3),
                                  if (facility["distance"] != null)
                                    Text(
                                      "${facility["type"]} • ${facility["distance"].toStringAsFixed(2)} km away",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blueAccent),
                                    )
                                  else
                                    Text(
                                      facility["type"],
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blueAccent),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.location_on,
                                color: Colors.black),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
