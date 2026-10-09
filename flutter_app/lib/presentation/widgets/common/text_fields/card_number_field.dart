import 'package:flutter/material.dart';

class CardNumberField extends StatelessWidget {
  const CardNumberField({
    super.key,
    this.controller,
    this.hintText = 'Card number',
  });

  final TextEditingController? controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.credit_card),
      ),
      inputFormatters: const [],
    );
  }
}
