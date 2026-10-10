import 'package:flutter/material.dart';

class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Text(message),
    );
  }
}
