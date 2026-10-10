import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
  });

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final active = index < rating.round();
        return Icon(
          active ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: active ? const Color(0xFFFFB703) : const Color(0xFFCBD5E1),
        );
      }),
    );
  }
}
