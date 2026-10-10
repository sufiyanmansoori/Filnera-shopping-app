import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SearchableAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchableAppBar({
    super.key,
    this.title,
    this.searchController,
    this.hintText = 'Search products',
    this.leading,
    this.onSearchChanged,
    this.onSubmitted,
    this.actions,
    this.onBack,
    this.backgroundColor,
  });

  final String? title;
  final TextEditingController? searchController;
  final String hintText;
  final Widget? leading;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSubmitted;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    final controller = searchController ?? TextEditingController();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        color: backgroundColor ?? Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                if (leading != null)
                  leading!
                else if (onBack != null)
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  )
                else
                  const SizedBox(width: 8),
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                if (actions != null) ...?actions,
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              onChanged: onSearchChanged,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: const Icon(
                  Icons.filter_list,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
