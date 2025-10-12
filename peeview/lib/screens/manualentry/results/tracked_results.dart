import 'package:flutter/material.dart';

class TrackedResultsCard extends StatelessWidget {
  final Map<String, dynamic>
  values; // expects keys: wbc, bacteria, transparency, protein

  const TrackedResultsCard({super.key, required this.values});

  int _parseResult(dynamic value, String key) {
    if (value == null) return 0;
    String val = value.toString().toLowerCase();

    // Numeric parsing
    final numeric = RegExp(r'\d+(\.\d+)?').firstMatch(val);
    if (numeric != null) {
      return double.tryParse(numeric.group(0)!)?.round() ?? 0;
    }

    switch (key) {
      /// ----------------------------
      /// Microscopy counts
      /// ----------------------------
      case 'wbc':
        if (value.contains("0-5/hpf")) return 2;
        if (value.contains("6-10/hpf")) return 4;
        if (value.contains("11-25/hpf")) return 6;
        if (value.contains("26-50/hpf")) return 8;
        if (value.contains(">50/hpf")) return 10;
        return 0;// White Blood Cells
      case 'rbc':
        if (value.contains("0-2/hpf")) return 2;
        if (value.contains("3-5/hpf")) return 4;
        if (value.contains("6-10/hpf")) return 6;
        if (value.contains("11-25/hpf")) return 8;
        if (value.contains(">25/hpf")) return 10;
        return 0;
          // Red Blood Cells
      case 'bacteria':
        if (value.contains(">50/hpf")) return 10;
        if (value.contains("26-50/hpf")) return 8;
        if (value.contains("Many")) return 6;
        if (value.contains("Moderate")) return 4;
        if (value.contains("Few")) return 2;
        return 0;

      /// ----------------------------
      /// Protein, Glucose, Bilirubin, Blood
      /// ----------------------------
      case 'protein':
        if (value.contains("Negative")) return 0;
        if (value.contains("Trace")) return 2;
        if (value.contains("+1")) return 4;
        if (value.contains("+2")) return 6;
        if (value.contains("+3")) return 8;
        if (value.contains("+4")) return 10;
        return 0;
      case 'glucose':
        if (value.contains("Negative")) return 0;
        if (value.contains("Trace")) return 2;
        if (value.contains("+1")) return 4;
        if (value.contains("+2")) return 6;
        if (value.contains("+3")) return 8;
        if (value.contains("+4")) return 10;
        return 0;
      case 'bilirubin':
        if (value.contains("+1")) return 2;
        if (value.contains("+2")) return 4;
        if (value.contains("+3")) return 6;
        if (value.contains("+4")) return 10;
        return 0;
      case 'blood':
        // e.g. "+1", "+2", "+3", "+4"
        return int.tryParse(value.replaceAll("+", "")) ?? 0;

      /// ----------------------------
      /// Ketones & Leukocytes
      /// ----------------------------
      case 'ketones':
      case 'leukocytes':
        if (value.toLowerCase() == "trace") return 1;
        if (value == "+1" || value.toLowerCase() == "small") return 2;
        if (value == "+2" || value.toLowerCase() == "moderate") return 3;
        if (value == "+3" || value.toLowerCase() == "large") return 4;
        return 0;

      /// ----------------------------
      /// Nitrites
      /// ----------------------------
      case 'nitrites':
        if (value.contains("Negative")) return 0;
        if (value.contains("Positive")) return 10;
        return 0;

      /// ----------------------------
      /// Transparency
      /// ----------------------------
      case 'transparency':
        switch (value.toLowerCase()) {
          case "clear":
            return 0;
          case "slightly hazy":
            return 2;
          case "hazy":
            return 4;
          case "cloudy":
            return 6;
          case "turbid":
            return 8;
        }
        return 0;

      /// ----------------------------
      /// Urine Color
      /// ----------------------------
      case 'color':
        switch (value) {
          case "Pale Yellow":
            return 0;
          case "Yellow":
            return 2;
          case "Dark Yellow":
            return 4;
          case "Amber":
            return 6;
          case "Orange":
            return 7;
          case "Red":
            return 8;
          case "Brown":
            return 9;
          case "Colorless":
            return 10;
        }
        return 0;

      /// ----------------------------
      /// Specific Gravity
      /// ----------------------------
      case 'specific_gravity':
        switch (value) {
          case "1.000":
            return 0;
          case "1.005":
            return 2;
          case "1.010":
            return 4;
          case "1.015":
            return 6;
          case "1.020":
            return 8;
          case "1.025":
            return 9;
          case "1.030+":
            return 10;
        }
        return 0;

      /// ----------------------------
      /// pH Level
      /// ----------------------------
      case 'ph_level':
        switch (value) {
          case "5.0":
            return 0;
          case "6.0":
            return 2;
          case "6.5":
            return 3;
          case "7.0":
            return 4;
          case "7.5":
            return 6;
          case "8.0":
            return 8;
          case "8.5":
            return 9;
          case "9.0+":
            return 10;
        }
        return 0;

      /// ----------------------------
      /// Urobilinogen
      /// ----------------------------
      case 'urobilinogen':
        if (value.contains("12+")) return 10;
        if (value.contains("8 mg/dL")) return 8;
        if (value.contains("4")) return 6;
        if (value.contains("2")) return 4;
        if (value.toLowerCase().contains("normal") ||
            value.toLowerCase().contains("trace"))
          return 2;
        return 0;

      /// ----------------------------
      /// Default fallback
      /// ----------------------------
      default:
        return int.tryParse(value) ?? 0;
    }
  }

  /// Helper to safely convert any Firestore value to int
  int _safeToInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ??
          defaultValue; // returns default if not numeric (e.g. "Clear")
    }
    return defaultValue;
  }

  Widget _resultRow({
    required String title,
    required int value,
    required List<String> labels,
    required List<Color> colors,
    required double markerPosition, // 0.0 - 1.0 relative position for indicator
    required String description,
    String badge = '',
  }) {
    assert(labels.length == colors.length);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (badge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB71C1C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 12),

          // Gradient bar with segments
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final segments = colors.length;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Row(
                    children: List.generate(segments, (i) {
                      return Expanded(
                        child: Container(
                          height: 18,
                          decoration: BoxDecoration(
                            color: colors[i],
                            borderRadius: BorderRadius.horizontal(
                              left: i == 0
                                  ? const Radius.circular(8)
                                  : Radius.zero,
                              right: i == segments - 1
                                  ? const Radius.circular(8)
                                  : Radius.zero,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  // marker
                  Positioned(
                    left: (width - 36) * markerPosition,
                    // compensate for marker width
                    child: Container(
                      width: 36,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        value.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Firestore Values: $values');

    // Parse all values
    int wbc = _parseResult(values['wbc_level'], 'wbc');
    int rbc = _parseResult(values['rbc_level'], 'rbc');
    int bacteria = _parseResult(values['bacteria_level'], 'bacteria');
    int transparency = _parseResult(values['transparency'], 'transparency');
    int protein = _parseResult(values['protein_level'], 'protein');
    int glucose = _parseResult(values['glucose_level'], 'glucose');
    int bilirubin = _parseResult(values['bilirubin_level'], 'bilirubin');
    int blood = _parseResult(values['blood_level'], 'blood');
    int leukocytes = _parseResult(values['leukocytes_level'], 'leukocytes');
    int nitrites = _parseResult(values['nitrites_level'], 'nitrites');
    int urobilinogen = _parseResult(values['urobilinogen_level'], 'urobilinogen');
    int ketones = _parseResult(values['ketones_level'], 'ketones');
    int color = _parseResult(values['color'], 'color');
    int sg = _parseResult(values['specific_gravity'], 'specific_gravity');
    int ph = _parseResult(values['ph_level'], 'ph_level');


    // Normalize positions (clamped to 0-1)
    double wbcPos = (wbc / 10).clamp(0.0, 1.0);
    double rbcPos = (rbc / 10).clamp(0.0, 1.0);
    double bacteriaPos = (bacteria / 10).clamp(0.0, 1.0);
    double transparencyPos = (transparency / 10).clamp(0.0, 1.0);
    double proteinPos = (protein / 4).clamp(0.0, 1.0);
    double glucosePos = (glucose / 4).clamp(0.0, 1.0);
    double bilirubinPos = (bilirubin / 4).clamp(0.0, 1.0);
    double bloodPos = (blood / 4).clamp(0.0, 1.0);
    double leukocytesPos = (leukocytes / 4).clamp(0.0, 1.0);
    double nitritesPos = nitrites.toDouble().clamp(0.0, 1.0);
    double urobilinogenPos = (urobilinogen / 10).clamp(0.0, 1.0);
    double ketonesPos = (ketones / 4).clamp(0.0, 1.0);
    double colorPos = (color / 10).clamp(0.0, 1.0);
    double sgPos = (sg / 10).clamp(0.0, 1.0);
    double phPos = (ph / 10).clamp(0.0, 1.0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tracked Results",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 🔹 Urine Color
          _resultRow(
            title: "Urine Color",
            value: color,
            labels: const ['PALE', 'YELLOW', 'DARK'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: colorPos,
            description: "Unusual color may indicate hydration or pathology.",
            badge: values['color'] ?? '',
          ),

          // 🔹 Transparency
          _resultRow(
            title: "Transparency",
            value: transparency,
            labels: const ['CLEAR', 'HAZY', 'TURBID'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: transparencyPos,
            description:
                "Hazy/Turbid urine may suggest dehydration or infection.",
            badge: values['transparency'] ?? '',
          ),

          // 🔹 Specific Gravity
          _resultRow(
            title: "Specific Gravity",
            value: sg,
            labels: const ['LOW', 'NORMAL', 'HIGH'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: sgPos,
            description: "Shows urine concentration (hydration status).",
            badge: values['specific_gravity'] ?? '',
          ),

          // 🔹 pH Level
          _resultRow(
            title: "pH Level",
            value: ph,
            labels: const ['ACIDIC', 'NEUTRAL', 'ALKALINE'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: phPos,
            description:
                "Acidic/alkaline urine may indicate metabolic conditions.",
            badge: values['ph_level'] ?? '',
          ),

          // 🔹 Protein
          _resultRow(
            title: "Protein",
            value: protein,
            labels: const ['NORMAL', 'MILD', 'SEVERE'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: proteinPos,
            description: "Proteinuria can indicate kidney involvement.",
            badge: values['protein_level'] ?? '',
          ),

          // 🔹 Glucose
          _resultRow(
            title: "Glucose",
            value: glucose,
            labels: const ['NORMAL', 'MILD', 'HIGH'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: glucosePos,
            description: "High glucose may indicate diabetes.",
            badge: values['glucose_level'] ?? '',
          ),

          // 🔹 Bilirubin
          _resultRow(
            title: "Bilirubin",
            value: bilirubin,
            labels: const ['NORMAL', 'MILD', 'HIGH'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: bilirubinPos,
            description: "Bilirubin presence may suggest liver disease.",
            badge: values['bilirubin'] ?? '',
          ),

          // 🔹 Blood
          _resultRow(
            title: "Blood (Erythrocytes)",
            value: blood,
            labels: const ['NEGATIVE', 'TRACE', 'HIGH'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: bloodPos,
            description:
                "Blood in urine may suggest kidney or urinary tract issues.",
            badge: values['blood_level'] ?? '',
          ),

          // 🔹 Leukocytes
          _resultRow(
            title: "Leukocytes",
            value: leukocytes,
            labels: const ['NORMAL', 'TRACE', 'HIGH'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: leukocytesPos,
            description: "Indicates white blood cells, may mean infection.",
            badge: values['leukocytes'] ?? '',
          ),

          // 🔹 Nitrites
          _resultRow(
            title: "Nitrites",
            value: nitrites,
            labels: const ['NEGATIVE', 'POSITIVE', 'HIGH'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: nitritesPos,
            description: "Positive nitrites may suggest bacterial UTI.",
            badge: values['nitrites'] ?? '',
          ),

          // 🔹 Urobilinogen
          _resultRow(
            title: "Urobilinogen",
            value: urobilinogen,
            labels: const ['NORMAL', 'ELEVATED', 'HIGH'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: urobilinogenPos,
            description: "High levels may suggest liver dysfunction.",
            badge: values['urobilinogen'] ?? '',
          ),

          // 🔹 Ketones
          _resultRow(
            title: "Ketones",
            value: ketones,
            labels: const ['NORMAL', 'MODERATE', 'HIGH'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: ketonesPos,
            description: "High ketones may indicate diabetes or starvation.",
            badge: values['ketones'] ?? '',
          ),

          // 🔹 RBC
          _resultRow(
            title: "Red Blood Cells (RBC)",
            value: rbc,
            labels: const ['LOW', 'NORMAL', 'HIGH'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: rbcPos,
            description: "RBC in urine may indicate bleeding or kidney issues.",
            badge: values['rbc_level'] ?? '',
          ),

          // 🔹 WBC
          _resultRow(
            title: "White Blood Cells (WBC)",
            value: wbc,
            labels: const ['LOW', 'NORMAL', 'HIGH'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: wbcPos,
            description: "Elevated WBC count may suggest infection.",
            badge: values['wbc_level'] ?? '',
          ),

          // 🔹 Bacteria
          _resultRow(
            title: "Bacteria",
            value: bacteria,
            labels: const ['NONE', 'FEW', 'MANY'],
            colors: const [
              Color(0xFF2E7D32),
              Color(0xFFF57C00),
              Color(0xFFB71C1C),
            ],
            markerPosition: bacteriaPos,
            description: "High bacteria count may indicate infection.",
            badge: values['bacteria_level'] ?? '',
          ),
        ],
      ),
    );
  }
}
