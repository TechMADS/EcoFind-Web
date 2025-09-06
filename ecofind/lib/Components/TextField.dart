import 'package:flutter/material.dart';

class textfield extends StatelessWidget {
  final String hintText, labelText;
  final IconData icon;
  final TextEditingController controller;

  const textfield({
    super.key,
    required this.hintText,
    required this.icon,
    required this.labelText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, //
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
