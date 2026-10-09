import 'package:flutter/material.dart';

class RatingInput extends StatefulWidget {
  const RatingInput({super.key, this.initialRating = 0, this.onRatingChanged});

  final double initialRating;
  final ValueChanged<double>? onRatingChanged;

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
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(index < _rating ? Icons.star : Icons.star_border),
          onPressed: () {
            setState(() => _rating = index + 1);
            widget.onRatingChanged?.call(_rating);
          },
        );
      }),
    );
  }
}
