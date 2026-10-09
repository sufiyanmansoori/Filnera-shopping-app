import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class FilterAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FilterAppBar({
    super.key,
    required this.title,
    this.onFilterPressed,
    this.onSearchPressed,
    this.trailing,
    this.leading,
    this.onBack,
    this.backgroundColor,
  });

  final String title;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onSearchPressed;
  final List<Widget>? trailing;
  final Widget? leading;
  final VoidCallback? onBack;
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: 0,
      automaticallyImplyLeading: leading == null && onBack != null,
      leading:
          leading ??
          (onBack != null
              ? IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                )
              : null),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        if (onSearchPressed != null)
          IconButton(
            onPressed: onSearchPressed,
            icon: const Icon(Icons.search_rounded),
          ),
        if (onFilterPressed != null)
          IconButton(
            onPressed: onFilterPressed,
            icon: const Icon(Icons.filter_list_rounded),
          ),
        if (trailing != null) ...?trailing,
      ],
    );
  }
}
