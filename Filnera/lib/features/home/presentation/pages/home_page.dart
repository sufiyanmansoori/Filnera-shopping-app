import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../../data/models/product_model.dart';
import '../../../admin/data/admin_product_store.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../widgets/auto_ad_carousel.dart';
import '../../../shop/shop_store.dart';
import '../../../navigation/data/category_navigation_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'All';
  final ScrollController _catalogScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedCategory = CategoryNavigationStore.selectedCategory.value;
    CategoryNavigationStore.selectedCategory.addListener(_onCategoryChanged);
  }

  @override
  void dispose() {
    CategoryNavigationStore.selectedCategory.removeListener(_onCategoryChanged);
    _catalogScrollController.dispose();
    super.dispose();
  }

  void _onCategoryChanged() {
    if (mounted) {
      setState(
        () => selectedCategory = CategoryNavigationStore.selectedCategory.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ProductModel>>(
      valueListenable: AdminProductStore.products,
      builder: (context, catalog, child) {
        final filteredProducts = selectedCategory == 'All'
            ? catalog.take(30).toList()
            : catalog
                  .where((product) => product.category == selectedCategory)
                  .take(30)
                  .toList();

        return Container(
          color: const Color(0xFFFFFAF7),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AutoAdCarousel(),
                const SizedBox(height: 20),
                if (selectedCategory == 'Fashion') ...[
                  _fashionBrandCarousel(catalog),
                  const SizedBox(height: 20),
                  _fashionDealsCarousel(catalog),
                  const SizedBox(height: 20),
                ],
                Text(
                  '$selectedCategory products (${filteredProducts.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const _CategoryIconStrip(),
                const SizedBox(height: 20),
                const _CategoryPillStrip(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Trending deals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'More',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/filters'),
                    icon: const Icon(Icons.tune),
                    label: const Text('Filters'),
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1200
                        ? 6
                        : constraints.maxWidth >= 800
                        ? 4
                        : constraints.maxWidth >= 560
                        ? 3
                        : 2;
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredProducts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        mainAxisExtent: 360,
                      ),
                      itemBuilder: (context, index) =>
                          ProductGridTile(product: filteredProducts[index]),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _CatalogProductStrip(
                  controller: _catalogScrollController,
                  products: catalog
                      .where((product) => product.id.startsWith('pdf-p'))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _fashionBrandCarousel(List<ProductModel> catalog) {
    final brands = ['Puma', 'French Connection', 'Levi\'s', 'Nike', 'Roadster'];
    return _horizontalSection(
      title: 'Top fashion brands',
      children: [
        for (var index = 0; index < brands.length; index++)
          Container(
            width: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: catalog[index % catalog.length].imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  brands[index],
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const Text(
                  'Min. 70% Off',
                  style: TextStyle(color: AppColors.success),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _fashionDealsCarousel(List<ProductModel> catalog) {
    final deals = catalog
        .where((product) => product.category == 'Fashion')
        .take(8)
        .toList();
    return _horizontalSection(
      title: 'Unmissable deals',
      children: [
        for (final product in deals)
          SizedBox(width: 176, child: ProductGridTile(product: product)),
      ],
    );
  }

  Widget _horizontalSection({
    required String title,
    required List<Widget> children,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: title == 'Unmissable deals' ? 360 : 240,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: children.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, index) => children[index],
        ),
      ),
    ],
  );
}

class _CatalogProductStrip extends StatelessWidget {
  const _CatalogProductStrip({
    required this.products,
    required this.controller,
  });

  final List<ProductModel> products;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'More products from our catalog',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  controller.animateTo(
                    controller.offset - 260,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  controller.animateTo(
                    controller.offset + 260,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ],
          ),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          SizedBox(
            height: 360,
            child: ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: 180,
                child: ProductGridTile(product: products[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryIconStrip extends StatelessWidget {
  const _CategoryIconStrip();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 106,
        child: LayoutBuilder(
          builder: (context, constraints) => ValueListenableBuilder<String>(
            valueListenable: CategoryNavigationStore.selectedCategory,
            builder: (context, selected, _) {
              final categories = CategoryNavigationStore.categories
                  .skip(1)
                  .toList();
              final count = categories.length;
              final fittedWidth =
                  (constraints.maxWidth - ((count - 1) * 10)) / count;
              final tileWidth = fittedWidth.clamp(68.0, 96.0);
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: count,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _HomeCategoryTile(
                    width: tileWidth,
                    label: category.$1,
                    icon: category.$2,
                    selected: selected == category.$1,
                    onTap: () {
                      CategoryNavigationStore.select(category.$1);
                      context.go('/');
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    ],
  );
}

class _CategoryPillStrip extends StatelessWidget {
  const _CategoryPillStrip();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Shop by category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'See all',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 50,
        child: ValueListenableBuilder<String>(
          valueListenable: CategoryNavigationStore.selectedCategory,
          builder: (context, selected, _) => ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: CategoryNavigationStore.categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = CategoryNavigationStore.categories[index];
              final isSelected = selected == category.$1;
              return ChoiceChip(
                label: Text(category.$1),
                selected: isSelected,
                onSelected: (_) => CategoryNavigationStore.select(category.$1),
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                showCheckmark: false,
              );
            },
          ),
        ),
      ),
    ],
  );
}

class _HomeCategoryTile extends StatefulWidget {
  const _HomeCategoryTile({
    required this.width,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double width;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_HomeCategoryTile> createState() => _HomeCategoryTileState();
}

class _HomeCategoryTileState extends State<_HomeCategoryTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        width: widget.width,
        height: 96,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.selected
              ? const Color(0xFFFFF5E8)
              : const Color(0xFFF8F7F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.selected ? AppColors.primary : AppColors.border,
            width: widget.selected ? 2 : 1,
          ),
          boxShadow: _hovered
              ? const [BoxShadow(color: Colors.black12, blurRadius: 8)]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: _hovered ? 1.1 : 1,
              child: _categoryIcon(),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _categoryIcon() {
    final icon = switch (widget.label) {
      'Home' => Icons.home_filled,
      'Travel' => Icons.flight,
      'Minutes' => Icons.bolt,
      _ => null,
    };

    if (icon == null) {
      return Text(widget.icon, style: const TextStyle(fontSize: 28));
    }

    return Icon(icon, size: 28, color: Colors.black87);
  }
}

class ProductGridTile extends StatelessWidget {
  const ProductGridTile({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: product.imageUrl.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          height: 125,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 125,
                          width: double.infinity,
                          child: Image(
                            image: productImageProvider(product.imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: ValueListenableBuilder<Set<String>>(
                    valueListenable: ShopStore.wishlist,
                    builder: (_, saved, _) => CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(
                          saved.contains(product.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () => ShopStore.toggleWishlist(product.id),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<CartProvider>().addItem(
                            CartItemModel(
                              id: product.id,
                              productId: product.id,
                              productName: product.name,
                              productImage: product.imageUrl,
                              price: product.price,
                              quantity: 1,
                              variant: 'Default',
                              seller: 'Manara Store',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')),
                          );
                        },
                        child: const Text('ADD TO CART'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        Flexible(
                          child: Text(
                            '${product.rating} (${product.reviewCount})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      AppFormatters.currency(product.price),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.currency(product.originalPrice),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
