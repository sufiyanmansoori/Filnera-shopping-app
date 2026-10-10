import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.enabled = true,
    this.loading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon),
              if (icon != null) const SizedBox(width: 8),
              Text(text),
            ],
          );

    return FilledButton(
      onPressed: enabled && !loading ? onPressed : null,
      child: child,
    );
  }
}
