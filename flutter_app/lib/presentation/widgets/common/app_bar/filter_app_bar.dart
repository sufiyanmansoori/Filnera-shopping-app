import 'package:flutter/material.dart';

class FilterAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FilterAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.onFilterPressed,
  });

  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onFilterPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final safeActions = <Widget>[];
    if (actions != null) safeActions.addAll(actions!);
    if (onFilterPressed != null) {
      safeActions.add(
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: onFilterPressed,
        ),
      );
    }

    return AppBar(
      title: title == null ? null : Text(title!),
      leading: leading,
      actions: safeActions,
    );
  }
}
