import 'package:flutter/material.dart';

class ProductCarousel extends StatelessWidget {
  const ProductCarousel({super.key, required this.items});

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => items[index],
      ),
    );
  }
}
