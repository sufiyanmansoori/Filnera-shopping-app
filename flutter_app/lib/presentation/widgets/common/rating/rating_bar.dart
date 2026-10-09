import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  const RatingBar({super.key, this.rating = 0, this.maxRating = 5});

  final double rating;
  final int maxRating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(maxRating, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Theme.of(context).colorScheme.secondary,
        );
      }),
    );
  }
}
