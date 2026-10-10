import 'package:flutter/material.dart';

class RefundStatus extends StatelessWidget {
  const RefundStatus({super.key, required this.status, required this.amount});

  final String status;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final safeStatus = status.toLowerCase();
    final color = switch (safeStatus) {
      'approved' => Colors.green,
      'processing' => Colors.orange,
      'rejected' => Colors.red,
      _ => Colors.blue,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '${status.toUpperCase()} · ₹${amount.toStringAsFixed(0)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
