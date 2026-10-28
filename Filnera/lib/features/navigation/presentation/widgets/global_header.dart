import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../search/presentation/widgets/search_bar_widget.dart';
import '../../data/category_navigation_store.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../../core/services/profile_store.dart';

class GlobalHeader extends StatelessWidget implements PreferredSizeWidget {
  const GlobalHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(132);

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.accent,
    elevation: 3,
    child: SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth < 1000;
          return Column(
            children: [
              SizedBox(
                height: isMobile ? 62 : 72,
                child: Container(
                  color: AppColors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isMobile
                      ? _mobileHeader(context)
                      : isTablet
                      ? _tabletHeader(context)
                      : _wideHeader(context),
                ),
              ),
              SizedBox(
                height: 60,
                child: Container(
                  color: Colors.white,
                  child: LayoutBuilder(
                    builder: (context, railConstraints) =>
                        ValueListenableBuilder<String>(
                          valueListenable:
                              CategoryNavigationStore.selectedCategory,
                          builder: (context, selected, _) {
                            final categoryCount =
                                CategoryNavigationStore.categories.length;
                            final fittedWidth =
                                (railConstraints.maxWidth -
                                    32 -
                                    ((categoryCount - 1) * 4)) /
                                categoryCount;
                            final itemWidth = fittedWidth.clamp(64.0, 104.0);
                            final gap = fittedWidth >= 64 ? 4.0 : 8.0;
                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: categoryCount,
                              separatorBuilder: (_, _) => SizedBox(width: gap),
                              itemBuilder: (context, index) {
                                final category =
                                    CategoryNavigationStore.categories[index];
                                return _CategoryItem(
                                  width: itemWidth,
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
              ),
            ],
          );
        },
      ),
    ),
  );

  Widget _wideHeader(BuildContext context) => Row(
    children: [
      _logo(context),
      const SizedBox(width: 32),
      Expanded(child: _search(context)),
      const SizedBox(width: 20),
      _loginMenu(context),
      _moreMenu(context),
      _cartButton(context),
    ],
  );

  Widget _tabletHeader(BuildContext context) => Row(
    children: [
      _logo(context),
      const SizedBox(width: 8),
      Expanded(child: _search(context)),
      _loginMenu(context, compact: true),
      _moreMenu(context),
      _cartButton(context),
    ],
  );

  Widget _mobileHeader(BuildContext context) => Row(
    children: [
      _logo(context, compact: true),
      const SizedBox(width: 8),
      Expanded(child: _search(context)),
      _cartButton(context),
    ],
  );

  Widget _logo(BuildContext context, {bool compact = false}) => InkWell(
    onTap: () {
      CategoryNavigationStore.select('All');
      context.go('/');
    },
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.logo,
          width: compact ? 30 : 34,
          height: compact ? 30 : 34,
        ),
        if (!compact) ...[
          const SizedBox(width: 8),
          const Text(
            'Manara Store',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _search(BuildContext context) => SearchBarWidget(
    onTap: () => context.go('/search'),
    onSearch: (query) {
      final trimmed = query.trim();
      final location = trimmed.isEmpty
          ? '/search'
          : Uri(path: '/search', queryParameters: {'q': trimmed}).toString();
      context.go(location);
    },
  );

  Widget _loginMenu(
    BuildContext context, {
    bool compact = false,
  }) => ValueListenableBuilder<Map<String, String>?>(
    valueListenable: ProfileStore.currentUser,
    builder: (context, user, _) {
      final isLoggedIn = user != null;
      final displayName = user?['name'] ?? 'Login';
      final items = isLoggedIn
          ? const [
              _MenuAction('profile', 'My Profile', Icons.person_outline),
              _MenuAction('orders', 'Orders', Icons.inventory_2_outlined),
              _MenuAction(
                'coupons',
                'Coupons',
                Icons.confirmation_number_outlined,
              ),
              _MenuAction('rewards', 'Supercoin', Icons.bolt_outlined),
              _MenuAction(
                'plus',
                'Manara Plus Zone',
                Icons.auto_awesome_outlined,
              ),
              _MenuAction(
                'wallet',
                'Saved Cards & Wallet',
                Icons.account_balance_wallet_outlined,
              ),
              _MenuAction(
                'addresses',
                'Saved Addresses',
                Icons.location_on_outlined,
              ),
              _MenuAction('wishlist', 'Wishlist', Icons.favorite_border),
              _MenuAction('gift', 'Gift Cards', Icons.card_giftcard_outlined),
              _MenuAction(
                'notifications',
                'Notifications',
                Icons.notifications_none,
              ),
              _MenuAction('scanpay', 'Scan to Pay', Icons.qr_code_scanner),
              _MenuAction('logout', 'Logout', Icons.logout),
            ]
          : const [
              _MenuAction(
                'signup',
                'New customer? Sign Up',
                Icons.person_add_alt_1_outlined,
              ),
              _MenuAction('profile', 'My Profile', Icons.person_outline),
              _MenuAction(
                'plus',
                'Manara Plus Zone',
                Icons.auto_awesome_outlined,
              ),
              _MenuAction('orders', 'Orders', Icons.inventory_2_outlined),
              _MenuAction('wishlist', 'Wishlist', Icons.favorite_border),
              _MenuAction(
                'seller',
                'Become a Seller',
                Icons.storefront_outlined,
              ),
              _MenuAction('rewards', 'Rewards', Icons.bolt_outlined),
              _MenuAction('gift', 'Gift Cards', Icons.card_giftcard_outlined),
              _MenuAction(
                'notifications',
                'Notifications',
                Icons.notifications_none,
              ),
              _MenuAction(
                'care',
                '24x7 Customer Care',
                Icons.support_agent_outlined,
              ),
              _MenuAction('scanpay', 'Scan to Pay', Icons.qr_code_scanner),
              _MenuAction('advertise', 'Advertise', Icons.campaign_outlined),
              _MenuAction('download', 'Download App', Icons.download_outlined),
            ];
      return _HoverMenu(
        tooltip: 'Login and account',
        items: items,
        onSelected: (value) => isLoggedIn
            ? _handleAction(context, value)
            : _handleGuestAction(context, value),
        triggerBuilder: (hovered) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline, color: Colors.white),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              _HoverArrow(hovered: hovered),
            ],
          ),
        ),
      );
    },
  );

  Widget _moreMenu(BuildContext context) => _HoverMenu(
    tooltip: 'More options',
    items: const [
      _MenuAction(
        'notifications',
        'Notification Settings',
        Icons.notifications_none,
      ),
      _MenuAction('seller', 'Become a Seller', Icons.storefront_outlined),
      _MenuAction(
        'add_product_image',
        'Sell/Add Product',
        Icons.add_photo_alternate_outlined,
      ),
      _MenuAction('advertise', 'Advertise', Icons.campaign_outlined),
      _MenuAction('download', 'Download App', Icons.download_outlined),
      _MenuAction('care', '24x7 Customer Care', Icons.support_agent_outlined),
    ],
    onSelected: (value) => _handleAction(context, value),
    triggerBuilder: (hovered) => Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('More', style: TextStyle(color: Colors.white)),
          _HoverArrow(hovered: hovered),
        ],
      ),
    ),
  );

  Widget _cartButton(BuildContext context) => IconButton(
    tooltip: 'Cart',
    onPressed: () => context.push('/cart'),
    icon: Consumer<CartProvider>(
      builder: (_, provider, _) => Badge(
        label: Text(
          '${provider.cart.items.fold<int>(0, (sum, item) => sum + item.quantity)}',
        ),
        isLabelVisible: provider.cart.items.isNotEmpty,
        backgroundColor: Colors.red,
        child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
      ),
    ),
  );

  void _handleAction(BuildContext context, String value) {
    switch (value) {
      case 'login':
        context.push('/login');
      case 'profile':
        context.push('/profile');
      case 'orders':
        context.push('/orders');
      case 'wishlist':
        context.push('/wishlist');
      case 'gift':
        context.push('/gift-cards');
      case 'addresses':
        context.push('/addresses');
      case 'wallet':
        context.push('/saved-payments');
      case 'coupons':
        context.push('/deals');
      case 'notifications':
        context.push('/notifications');
      case 'scanpay':
        context.push('/scan-and-pay');
      case 'logout':
        ProfileStore.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have been logged out.')),
        );
      default:
        if (value != 'plus' && value != 'rewards' && value != 'notifications') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$value is ready for your account.')),
          );
        }
    }
  }

  void _handleGuestAction(BuildContext context, String value) {
    switch (value) {
      case 'signup':
        context.push('/register');
      case 'seller':
        _showMessage(context, 'Seller registration will open soon.');
      case 'add_product_image':
        context.push('/add-product-image');
      case 'advertise':
        _showMessage(context, 'Advertising tools will open soon.');
      case 'download':
        _showMessage(context, 'The Manara app download link is coming soon.');
      case 'care':
        _showMessage(
          context,
          'Customer care is available for orders, returns and payments.',
        );
      case 'notifications':
        context.push('/notifications');
      default:
        _showLoginRequired(context, value);
    }
  }

  void _showLoginRequired(BuildContext context, String feature) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Login required'),
        content: Text('Please login to use $feature.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push('/register');
            },
            child: const Text('SIGN UP'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push('/login');
            },
            child: const Text('LOGIN'),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MenuAction {
  const _MenuAction(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}

class _HoverArrow extends StatelessWidget {
  const _HoverArrow({required this.hovered});

  final bool hovered;

  @override
  Widget build(BuildContext context) => AnimatedRotation(
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutBack,
    turns: hovered ? .5 : 0,
    child: AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      scale: hovered ? 1.18 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, hovered ? -2 : 0, 0),
        child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      ),
    ),
  );
}

class _HoverMenu extends StatefulWidget {
  const _HoverMenu({
    required this.triggerBuilder,
    required this.items,
    required this.onSelected,
    required this.tooltip,
  });

  final Widget Function(bool hovered) triggerBuilder;
  final List<_MenuAction> items;
  final ValueChanged<String> onSelected;
  final String tooltip;

  @override
  State<_HoverMenu> createState() => _HoverMenuState();
}

class _HoverMenuState extends State<_HoverMenu> {
  final _link = LayerLink();
  OverlayEntry? _entry;
  Timer? _closeTimer;
  bool _hovered = false;

  @override
  void dispose() {
    _closeTimer?.cancel();
    _removeMenu();
    super.dispose();
  }

  void _showMenu() {
    _closeTimer?.cancel();
    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (overlayContext) {
        final size = MediaQuery.sizeOf(overlayContext);
        final screenWidth = size.width;
        final isDesktop = screenWidth >= 1100;
        final isTablet = screenWidth >= 768;

        final menuWidth = isDesktop
            ? 280.0
            : isTablet
            ? 270.0
            : math.min(260.0, screenWidth - 44);

        final maxHeight = math.min(420.0, math.max(250.0, size.height - 90));

        return Positioned(
          width: menuWidth,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            offset: const Offset(0, 44),
            followerAnchor: Alignment.topLeft,
            targetAnchor: Alignment.bottomLeft,
            child: MouseRegion(
              onEnter: (_) => _closeTimer?.cancel(),
              onExit: (_) => _scheduleClose(),
              child: Material(
                elevation: 8,
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: math.min(250.0, menuWidth),
                    maxWidth: menuWidth,
                    maxHeight: maxHeight,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        color: AppColors.accent,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'More',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Scrollbar(
                          thumbVisibility: false,
                          thickness: 6,
                          radius: const Radius.circular(8),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shrinkWrap: true,
                            itemCount: widget.items.length,
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              thickness: 0.6,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final item = widget.items[index];
                              return InkWell(
                                onTap: () {
                                  _removeMenu();
                                  widget.onSelected(item.value);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 13,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 20,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 180), _removeMenu);
  }

  void _removeMenu() {
    _closeTimer?.cancel();
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
    link: _link,
    child: MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        _showMenu();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _scheduleClose();
      },
      child: Semantics(
        button: true,
        label: widget.tooltip,
        child: GestureDetector(
          onTap: () {
            if (_entry == null) {
              _showMenu();
            } else {
              _removeMenu();
            }
          },
          child: widget.triggerBuilder(_hovered || _entry != null),
        ),
      ),
    ),
  );
}

class _CategoryItem extends StatefulWidget {
  const _CategoryItem({
    required this.width,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final double width;
  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    cursor: SystemMouseCursors.click,
    child: InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        width: widget.width,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: _hovered ? 1.12 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 38,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? AppColors.primary.withValues(alpha: .12)
                      : _hovered
                      ? AppColors.secondary.withValues(alpha: .08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _categoryIcon(),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: widget.selected || _hovered
                    ? FontWeight.w900
                    : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3,
              width: widget.selected ? 44 : (_hovered ? 28 : 0),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
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
      return Text(widget.icon, style: const TextStyle(fontSize: 20));
    }

    return Icon(icon, size: 20, color: Colors.black87);
  }
}

/*
class _CategoryItemLegacy extends StatelessWidget {
  const _CategoryItemLegacy({
    required this.width,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 38,
            height: 30,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: .12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 22,
              color: selected ? AppColors.secondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 3,
            width: selected ? 44 : 0,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    ),
  );
}
*/
