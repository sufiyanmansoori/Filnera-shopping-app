import 'package:flutter/material.dart';

class SellerCard extends StatelessWidget {
  const SellerCard({
    super.key,
    required this.name,
    this.rating = 0,
    this.onTap,
  });

  final String name;
  final double rating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.store)),
        title: Text(name),
        subtitle: Text('Rating: ${rating.toStringAsFixed(1)}'),
        onTap: onTap,
      ),
    );
  }
}
