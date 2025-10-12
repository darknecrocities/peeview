import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class ClinicData {
  static List<Map<String, dynamic>> clinics = [];

  static Future<void> loadClinics() async {
    final rawData = await rootBundle.loadString('lib/data/philippines.csv');
    final csvTable = const CsvToListConverter().convert(rawData, eol: '\n');
    clinics = csvTable.skip(1).map((row) {
      return {
        "name": row[6] ?? "Unknown Clinic",
        "address":
            "${row[27] ?? ""} ${row[28] ?? ""}, ${row[30] ?? ""}", // housenumber, street, city
        "lat": row[0] != null ? double.tryParse(row[0].toString()) ?? 0.0 : 0.0,
        "lng": row[1] != null ? double.tryParse(row[1].toString()) ?? 0.0 : 0.0,
        "open": true,
      };
    }).toList();
  }

  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371;
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180);

  /// Find nearest clinic
  static Map<String, dynamic>? findNearest(double userLat, double userLng) {
    if (clinics.isEmpty) return null;

    clinics.sort((a, b) {
      double distA = _calculateDistance(userLat, userLng, a["lat"], a["lng"]);
      double distB = _calculateDistance(userLat, userLng, b["lat"], b["lng"]);
      return distA.compareTo(distB);
    });

    return clinics.first;
  }

  /// Search clinics by keyword (limit 5)
  static List<Map<String, dynamic>> searchClinics(String keyword) {
    if (keyword.isEmpty) return clinics.take(5).toList();

    final results = clinics.where((clinic) {
      final name = clinic["name"]?.toString().toLowerCase() ?? "";
      final address = clinic["address"]?.toString().toLowerCase() ?? "";
      return name.contains(keyword.toLowerCase()) ||
          address.contains(keyword.toLowerCase());
    }).toList();

    return results.take(5).toList();
  }
}
