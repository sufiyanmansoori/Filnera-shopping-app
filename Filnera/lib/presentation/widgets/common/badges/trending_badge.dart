import 'package:flutter/material.dart';

class TrendingBadge extends StatelessWidget {
  const TrendingBadge({super.key, this.label = 'Trending'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
