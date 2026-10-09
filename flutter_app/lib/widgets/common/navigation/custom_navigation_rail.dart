import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onDestinationSelected,
  });

  final List<NavigationRailDestination> items;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: Colors.white,
      selectedIconTheme: const IconThemeData(color: AppColors.primary),
      unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
      labelType: NavigationRailLabelType.selected,
      destinations: items,
    );
  }
}
