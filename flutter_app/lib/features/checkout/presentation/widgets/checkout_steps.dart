import 'package:flutter/material.dart';

class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          _StepChip(label: 'Cart', active: true),
          SizedBox(width: 8),
          Expanded(child: Divider()),
          SizedBox(width: 8),
          _StepChip(label: 'Checkout', active: true),
          SizedBox(width: 8),
          Expanded(child: Divider()),
          SizedBox(width: 8),
          _StepChip(label: 'Review', active: false),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.orange.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: active ? Colors.orange.shade900 : Colors.grey.shade700,
        ),
      ),
    );
  }
}
