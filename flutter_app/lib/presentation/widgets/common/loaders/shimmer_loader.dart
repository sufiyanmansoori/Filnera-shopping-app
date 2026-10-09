import 'package:flutter/material.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    super.key,
    this.height = 100,
    this.width = double.infinity,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
