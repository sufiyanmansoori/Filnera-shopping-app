import 'package:flutter/material.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.radius = 12,
    this.baseColor,
    this.highlightColor,
  });

  final double height;
  final double width;
  final double radius;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: baseColor ?? Colors.grey.shade200,
      ),
    );
  }
}
