import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String countryCode;
  final Function(String) onCountryCodeChanged;

  const PhoneField({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.onCountryCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade400, width: 1)),
            ),
            child: CountryCodePicker(
              onChanged: (code) => onCountryCodeChanged(code.dialCode!),
              initialSelection: "PH",
              favorite: const ["+63", "PH"],
              showFlag: true,
              showDropDownButton: true,
              showFlagDialog: true,
              textStyle: const TextStyle(fontSize: 14, color: Colors.black),
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Phone Number",
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
