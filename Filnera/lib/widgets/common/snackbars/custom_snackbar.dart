import 'package:flutter/material.dart';

class CustomSnackbar {
  const CustomSnackbar._();

  static void show({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }
}
