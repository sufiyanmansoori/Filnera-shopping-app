import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.error_outline_rounded,
        color: AppColors.error,
        size: 40,
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: onRetry ?? () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
