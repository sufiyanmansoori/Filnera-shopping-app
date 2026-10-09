import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({
    super.key,
    required this.onGoogleTap,
    required this.onAppleTap,
  });

  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onGoogleTap,
            icon: const Icon(Icons.g_mobiledata_rounded),
            label: const Text('Google'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAppleTap,
            icon: const Icon(Icons.apple),
            label: const Text('Apple'),
          ),
        ),
      ],
    );
  }
}
