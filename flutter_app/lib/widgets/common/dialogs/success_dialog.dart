import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    super.key,
    required this.message,
    this.title = 'Success',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.check_circle_outline_rounded,
        color: AppColors.success,
        size: 40,
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(backgroundColor: AppColors.success),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
