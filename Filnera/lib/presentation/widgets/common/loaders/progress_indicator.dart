import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({super.key, this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return const CircularProgressIndicator();
    }
    return LinearProgressIndicator(value: value);
  }
}
