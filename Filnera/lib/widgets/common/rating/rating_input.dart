import 'package:flutter/material.dart';

class RatingInput extends StatefulWidget {
  const RatingInput({super.key, this.initialRating = 0, this.onChanged});

  final double initialRating;
  final ValueChanged<double>? onChanged;

  @override
  State<RatingInput> createState() => _RatingInputState();
}

class _RatingInputState extends State<RatingInput> {
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final filled = _rating >= starIndex;
        return IconButton(
          onPressed: () {
            setState(() => _rating = starIndex.toDouble());
            widget.onChanged?.call(_rating);
          },
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled ? Colors.amber : Colors.grey,
          ),
        );
      }),
    );
  }
}
