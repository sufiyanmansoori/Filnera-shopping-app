import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.barrierDismissible = true,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final bool barrierDismissible;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(title: title, content: content, actions: actions);
  }
}
