import 'package:flutter/material.dart';

class ReturnStatusScreen extends StatelessWidget {
  const ReturnStatusScreen({
    super.key,
    this.status = 'approved',
    this.refundAmount = 0,
  });

  final String status;
  final double refundAmount;

  @override
  Widget build(BuildContext context) {
    final safeStatus = status.toLowerCase();
    final color = switch (safeStatus) {
      'approved' => Colors.green,
      'processing' => Colors.orange,
      'rejected' => Colors.red,
      _ => Colors.blue,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Return Status')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.w700, color: color),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your return request is being processed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  'Refund amount: ₹${refundAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
