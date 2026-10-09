import 'package:flutter/material.dart';

class SearchableAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchableAppBar({
    super.key,
    required this.searchController,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.leading,
    this.actions,
  });

  final TextEditingController searchController;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      actions: actions,
      title: TextField(
        controller: searchController,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
