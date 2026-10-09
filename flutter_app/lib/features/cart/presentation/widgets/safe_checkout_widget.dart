import 'package:flutter/material.dart';

class SafeCheckoutWidget extends StatelessWidget {
  const SafeCheckoutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.security_outlined, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text('Safe and secure checkout')),
          ],
        ),
      ),
    );
  }
}
