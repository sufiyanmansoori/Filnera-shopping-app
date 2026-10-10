import 'package:flutter/material.dart';

class RateProductWidget extends StatefulWidget {
  const RateProductWidget({super.key, required this.onRated});

  final ValueChanged<int> onRated;

  @override
  State<RateProductWidget> createState() => _RateProductWidgetState();
}

class _RateProductWidgetState extends State<RateProductWidget> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate this product',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final selected = index < _rating;
            return IconButton(
              onPressed: () {
                setState(() => _rating = index + 1);
                widget.onRated(_rating);
              },
              icon: Icon(
                selected ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 28,
              ),
            );
          }),
        ),
      ],
    );
  }
}
