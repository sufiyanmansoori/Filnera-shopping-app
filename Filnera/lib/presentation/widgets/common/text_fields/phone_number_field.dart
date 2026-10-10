import 'package:flutter/material.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    this.controller,
    this.hintText = '+1 555 123 4567',
  });

  final TextEditingController? controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.phone),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
