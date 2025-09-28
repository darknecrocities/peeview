import 'package:flutter/material.dart';

class ClinicCard extends StatelessWidget {
  final Map<String, dynamic> clinic;
  final String distance;
  const ClinicCard({Key? key, required this.clinic, required this.distance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blue, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clinic["name"],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(clinic["open"] ? "Open" : "Closed",
                    style: TextStyle(
                        color: clinic["open"] ? Colors.green : Colors.red)),
              ],
            ),
          ),
          Text(distance, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class ClinicListItem extends StatelessWidget {
  final Map<String, dynamic> clinic;
  final VoidCallback onTap;
  const ClinicListItem({Key? key, required this.clinic, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.location_on, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
