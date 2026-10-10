import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key, this.message = 'Please wait...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(child: Text(message)),
        ],
      ),
    );
  }
}
