import 'package:flutter/material.dart';

class OtpTextField extends StatelessWidget {
  const OtpTextField({super.key, required this.length, this.controller});

  final int length;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(length, (index) {
        return Container(
          width: 48,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
          ),
        );
      }),
    );
  }
}
