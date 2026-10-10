import 'package:flutter/material.dart';

class ProductOffersWidget extends StatelessWidget {
  const ProductOffersWidget({super.key, required this.offers});

  final List<String> offers;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Offers', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...offers.map(
              (offer) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(offer)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
