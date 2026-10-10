import 'package:flutter/material.dart';

class NewBadge extends StatelessWidget {
  const NewBadge({super.key, this.label = 'New'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
