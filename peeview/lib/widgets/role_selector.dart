import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  final String role;
  final String assetPath;
  final String selectedRole;
  final Function(String) onSelect;

  const RoleSelector({
    super.key,
    required this.role,
    required this.assetPath,
    required this.selectedRole,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => onSelect(role),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00247D) : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            Image.asset(assetPath, height: 70),
            const SizedBox(height: 6),
            Text(
              role.toUpperCase(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF00247D) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
