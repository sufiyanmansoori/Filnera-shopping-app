import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.onBack,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.titleSpacing,
    this.toolbarHeight,
    this.bottom,
    this.leadingWidth,
  });

  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final double? titleSpacing;
  final double? toolbarHeight;
  final PreferredSizeWidget? bottom;
  final double? leadingWidth;

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final effectiveColor = foregroundColor ?? AppColors.textPrimary;

    return AppBar(
      automaticallyImplyLeading: leading == null && onBack != null,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: effectiveColor,
      elevation: elevation,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      leading:
          leading ??
          (onBack != null
              ? IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  tooltip: 'Back',
                )
              : null),
      title: title != null
          ? Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: effectiveColor,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
      actions: actions,
      bottom: bottom,
    );
  }
}
