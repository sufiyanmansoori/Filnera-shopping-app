import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black54,
    builder: builder,
  );
}

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.icon,
    this.backgroundColor,
  });

  final String? title;
  final Widget? content;
  final List<Widget>? actions;
  final Widget? icon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: icon,
      title: title != null
          ? Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            )
          : null,
      content: content,
      actions: actions,
    );
  }
}
