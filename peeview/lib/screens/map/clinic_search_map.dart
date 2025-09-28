// clinic_search_map.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

class ClinicSearchMap extends StatefulWidget {
  final List<Map<String, dynamic>> clinics;

  // 👇 add optional selected clinic
  final Map<String, dynamic>? selectedClinic;

  const ClinicSearchMap({
    Key? key,
    required this.clinics,
    this.selectedClinic,
  }) : super(key: key);

  @override
  State<ClinicSearchMap> createState() => _ClinicSearchMapState();
}


class _ClinicSearchMapState extends State<ClinicSearchMap> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();
  LocationData? _currentLocation;

  Set<Marker> _markers = {};
  String _searchQuery = "clinic";
  bool _loading = false;

  Timer? _debounce;
  Map<String, dynamic>? _selectedClinic;
  List<Map<String, dynamic>> _allClinics = [];

  static const String apiKey = "AIzaSyDE--Gb6spVlLkqlylj3vPBphoKM9aqllI";

  @override
  void initState() {
    super.initState();
    _loadClinicsFromCSV(); // load local csv
    if (widget.clinics != null && widget.clinics!.isNotEmpty) {
      _setMarkersFromList(widget.clinics!);
    } else {
      _getCurrentLocation();
    }
  }

  /// Load clinics from philippine.csv in assets
  Future<void> _loadClinicsFromCSV() async {
    final rawData = await rootBundle.loadString("lib/data/philippines.csv");
    List<List<dynamic>> rows = const CsvToListConverter().convert(rawData);

    final clinics = rows.skip(1).map((row) {
      return {
        "name": row.isNotEmpty && row[0] != null ? row[0].toString() : "Unnamed Clinic",
        "address": row.length > 1 && row[1] != null ? row[1].toString() : "No address provided",
        "lat": row.length > 2 && row[2] != null ? (row[2] as num).toDouble() : 0.0,
        "lng": row.length > 3 && row[3] != null ? (row[3] as num).toDouble() : 0.0,
        "status": row.length > 4 && row[4] != null ? row[4].toString() : "Open",
        "distance": row.length > 5 && row[5] != null ? row[5].toString() : "",
      };
    }).toList();

    setState(() {
      _allClinics = clinics;
    });
  }


  void _setMarkersFromList(List<Map<String, dynamic>> clinicsList) {
    final newMarkers = clinicsList.map((clinic) {
      final id = clinic["name"] ?? clinic["address"] ?? clinic["lat"].toString();
      return Marker(
        markerId: MarkerId(id),
        position: LatLng(clinic["lat"], clinic["lng"]),
        infoWindow: InfoWindow(title: clinic["name"], snippet: clinic["address"]),
        onTap: () {
          setState(() {
            _selectedClinic = clinic;
          });
        },
      );
    }).toSet();

    setState(() {
      _markers = newMarkers;
    });
  }

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

      _currentLocation = await _location.getLocation();

      if (_currentLocation != null && _controller.isCompleted) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          14,
        ));
      }

      if ((widget.clinics == null || widget.clinics!.isEmpty) &&
          _allClinics.isNotEmpty) {
        _setMarkersFromList(_allClinics.take(5).toList());
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  /// Debounced search from CSV
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        // Reset markers to all or default first few clinics
        _setMarkersFromList(_allClinics.take(5).toList());
        return;
      }

      final filtered = _allClinics.where((clinic) {
        final name = (clinic["name"] ?? "").toString().toLowerCase();
        final address = (clinic["address"] ?? "").toString().toLowerCase();
        return name.contains(query.toLowerCase()) || address.contains(query.toLowerCase());
      }).toList();

      if (filtered.isNotEmpty) {
        _setMarkersFromList(filtered);
        // Optional: auto-zoom to first filtered clinic
        _goToLatLng(filtered.first["lat"], filtered.first["lng"]);
      } else {
        // Clear markers if nothing matches
        setState(() {
          _markers = {};
        });
      }
    });
  }


  Future<void> _goToLatLng(double lat, double lng, {double zoom = 15}) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), zoom));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(14.5995, 120.9842), // Manila default
              zoom: 6,
            ),
            myLocationEnabled: true,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) async {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
              if (_allClinics.isNotEmpty) {
                final first = _allClinics.first;
                await controller.animateCamera(CameraUpdate.newLatLngZoom(
                  LatLng(first["lat"], first["lng"]),
                  14,
                ));
              }
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
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.blue),
                  hintText: "Search clinics/hospitals...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          if (_loading)
            const Center(child: CircularProgressIndicator()),

          // Bottom Card when marker is clicked
          if (_selectedClinic != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedClinic?["name"] ?? "Unknown Clinic",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(_selectedClinic?["address"] ?? "No address available"),
                      if ((_selectedClinic?["distance"] ?? "").toString().isNotEmpty)
                        Text("Distance: ${_selectedClinic!["distance"]}"),
                      Text(
                        (_selectedClinic?["status"] ?? "Open").toString(),
                        style: TextStyle(
                          color: (_selectedClinic?["status"] ?? "Open").toString().toLowerCase() == "open"
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: handle booking action
                        },
                        child: const Text("Book Now"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
