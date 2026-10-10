import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key, this.height = 1, this.color});

  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      color: color ?? Theme.of(context).dividerColor,
    );
  }
}
