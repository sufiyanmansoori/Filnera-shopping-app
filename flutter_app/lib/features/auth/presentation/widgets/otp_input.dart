import 'package:flutter/material.dart';

class OtpInput extends StatelessWidget {
  const OtpInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.length = 6,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int length;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: length,
      inputFormatters: const [],
      decoration: InputDecoration(
        hintText: 'Enter OTP',
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onChanged: onChanged,
      validator: (value) {
        if ((value ?? '').length != length) {
          return 'Enter the complete $length-digit code.';
        }
        return null;
      },
    );
  }
}
