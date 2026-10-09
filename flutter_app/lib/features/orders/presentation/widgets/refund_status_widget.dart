import 'package:flutter/material.dart';

class RefundStatusWidget extends StatelessWidget {
  const RefundStatusWidget({
    super.key,
    required this.status,
    required this.amount,
  });

  final String status;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(status, style: Theme.of(context).textTheme.titleMedium),
                  Text('Refund amount: ₹${amount.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
