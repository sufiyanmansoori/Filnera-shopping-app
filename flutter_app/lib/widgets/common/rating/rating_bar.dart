import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  const RatingBar({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.color = Colors.amber,
  });

  final double rating;
  final int maxRating;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final filled = index < rating.round();
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: filled ? color : Colors.grey.shade400,
        );
      }),
    );
  }
}
