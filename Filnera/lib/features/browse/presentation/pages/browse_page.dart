import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  String _selectedCategory = 'All';

  final List<_Category> _categories = const [
    _Category('All', Icons.apps_rounded),
    _Category('Mobiles', Icons.phone_android_rounded),
    _Category('Fashion', Icons.checkroom_rounded),
    _Category('Electronics', Icons.electrical_services_rounded),
    _Category('Home', Icons.home_rounded),
    _Category('Grocery', Icons.local_grocery_store_rounded),
    _Category('Deals', Icons.local_offer_rounded),
  ];

  final List<_BrowseFeature> _features = const [
    _BrowseFeature(
      title: 'Smart Phones',
      subtitle: 'Mobiles',
      icon: Icons.phone_android_rounded,
      route: '/search',
      category: 'Mobiles',
    ),
    _BrowseFeature(
      title: 'Mobile Accessories',
      subtitle: 'Mobiles',
      icon: Icons.headphones_rounded,
      route: '/search',
      category: 'Mobiles',
    ),
    _BrowseFeature(
      title: 'Women Fashion',
      subtitle: 'Fashion',
      icon: Icons.female_rounded,
      route: '/search',
      category: 'Fashion',
    ),
    _BrowseFeature(
      title: 'Men Fashion',
      subtitle: 'Fashion',
      icon: Icons.person_rounded,
      route: '/search',
      category: 'Fashion',
    ),
    _BrowseFeature(
      title: 'Home Decor',
      subtitle: 'Home',
      icon: Icons.home_outlined,
      route: '/search',
      category: 'Home',
    ),
    _BrowseFeature(
      title: 'Appliances',
      subtitle: 'Home',
      icon: Icons.kitchen_rounded,
      route: '/search',
      category: 'Home',
    ),
    _BrowseFeature(
      title: 'Daily Grocery',
      subtitle: 'Grocery',
      icon: Icons.shopping_basket_rounded,
      route: '/search',
      category: 'Grocery',
    ),
    _BrowseFeature(
      title: 'Electronics Deals',
      subtitle: 'Electronics',
      icon: Icons.laptop_chromebook_rounded,
      route: '/search',
      category: 'Electronics',
    ),
    _BrowseFeature(
      title: 'Flash Deals',
      subtitle: 'Deals',
      icon: Icons.flash_on_rounded,
      route: '/deals',
      category: 'Deals',
    ),
    _BrowseFeature(
      title: 'Orders & Returns',
      subtitle: 'Orders',
      icon: Icons.receipt_long_rounded,
      route: '/orders',
      category: 'All',
    ),
    _BrowseFeature(
      title: 'Wishlist',
      subtitle: 'Saved Items',
      icon: Icons.favorite_border_rounded,
      route: '/wishlist',
      category: 'All',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _features.where((item) {
      if (_selectedCategory == 'All') return true;
      return item.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Browse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final selected = _selectedCategory == category.name;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category.icon, size: 16),
                          const SizedBox(width: 6),
                          Text(category.name),
                        ],
                      ),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category.name),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.45,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _BrowseFeatureTile(feature: item);
                    },
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SmallNavButton(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    route: '/',
                  ),
                  _SmallNavButton(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Cart',
                    route: '/cart',
                  ),
                  _SmallNavButton(
                    icon: Icons.menu_rounded,
                    label: 'Browse',
                    selected: true,
                    route: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrowseFeatureTile extends StatelessWidget {
  const _BrowseFeatureTile({required this.feature});

  final _BrowseFeature feature;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (feature.route == '/search') {
            context.push('/search');
            return;
          }
          if (feature.route == '/deals') {
            context.push('/deals');
            return;
          }
          if (feature.route == '/orders') {
            context.push('/orders');
            return;
          }
          if (feature.route == '/wishlist') {
            context.push('/wishlist');
            return;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(feature.icon, color: AppColors.primary, size: 30),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      feature.subtitle,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                feature.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Open ${feature.subtitle} workspace',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallNavButton extends StatelessWidget {
  const _SmallNavButton({
    required this.icon,
    required this.label,
    required this.route,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final String? route;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: route == null
          ? null
          : () {
              if (route == '/') {
                context.go('/');
              } else {
                context.push(route!);
              }
            },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? AppColors.primary : AppColors.textSecondary,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Category {
  const _Category(this.name, this.icon);

  final String name;
  final IconData icon;
}

class _BrowseFeature {
  const _BrowseFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.category,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final String category;
}
