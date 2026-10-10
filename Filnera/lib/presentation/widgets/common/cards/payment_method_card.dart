import 'package:flutter/material.dart';

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.title,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon ?? Icons.payment),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
              if (selected) const Icon(Icons.check),
            ],
          ),
        ),
      ),
    );
  }
}
