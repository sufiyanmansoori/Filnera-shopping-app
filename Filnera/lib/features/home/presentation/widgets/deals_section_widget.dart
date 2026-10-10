import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';

class DealsSectionWidget extends StatelessWidget {
  const DealsSectionWidget({super.key, required this.deals});

  final List<HomeDealEntity> deals;

  @override
  Widget build(BuildContext context) {
    if (deals.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: deals.length,
        itemBuilder: (context, index) {
          final deal = deals[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(deal.discount),
                    const Spacer(),
                    Text(
                      deal.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
