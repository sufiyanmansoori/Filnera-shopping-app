import 'package:flutter/material.dart';

class CustomNavigationRail extends StatelessWidget {
  const CustomNavigationRail({
    super.key,
    required this.items,
    this.selectedIndex = 0,
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
      destinations: items,
      labelType: NavigationRailLabelType.all,
    );
  }
}
