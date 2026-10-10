import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String price;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(price, style: Theme.of(context).textTheme.bodyLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
