import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
