import 'package:flutter/material.dart';

class ProductCarousel extends StatelessWidget {
  const ProductCarousel({
    super.key,
    required this.items,
    this.itemBuilder,
    this.height = 220,
  });

  final List<dynamic> items;
  final Widget Function(BuildContext context, int index, dynamic item)?
  itemBuilder;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 180,
            child: itemBuilder != null
                ? itemBuilder!(context, index, item)
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
