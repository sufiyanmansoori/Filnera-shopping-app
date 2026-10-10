import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../browse/presentation/pages/browse_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../widgets/global_header.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.child});

  final Widget? child;
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  DateTime? _lastBackPress;
  final List<String> _routeStack = ['/'];

  void _rememberRoute(String route) {
    if (_routeStack.isEmpty || _routeStack.last != route) {
      _routeStack.add(route);
    }
  }

  Future<void> _handleBack() async {
    final router = GoRouter.of(context);

    if (router.canPop()) {
      if (context.mounted) {
        context.pop();
      }
      return;
    }

    if (_routeStack.length > 1) {
      _routeStack.removeLast();
      final target = _routeStack.last;
      if (target == '/') {
        setState(() => index = 0);
      }
      if (mounted) context.go(target);
      return;
    }

    if (index != 0) {
      setState(() => index = 0);
      if (mounted) context.go('/');
      return;
    }

    final now = DateTime.now();
    final previous = _lastBackPress;
    if (previous != null &&
        now.difference(previous) <= const Duration(seconds: 2)) {
      _lastBackPress = null;
      return;
    }
    _lastBackPress = now;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Press back again to exit'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: const GlobalHeader(),
        body:
            widget.child ??
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(index),
                child: [
                  const HomePage(),
                  const ProfilePage(),
                  const CartScreen(),
                  const CartScreen(),
                  const HomePage(),
                  const HomePage(),
                ][index],
              ),
            ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            indicatorColor: AppColors.primary.withValues(alpha: 0.14),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                color: states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : Colors.grey.shade700,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w800
                    : FontWeight.w500,
                fontSize: 11,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : Colors.grey.shade700,
                size: 24,
              ),
            ),
          ),
          child: NavigationBar(
            height: 70,
            elevation: 4,
            selectedIndex: index,
            onDestinationSelected: (i) {
              if (i == 2) {
                _openWallet();
                return;
              }
              if (i == 4) {
                _openBrowse();
                return;
              }
              setState(() => index = i);
              if (i == 0) {
                _rememberRoute('/');
                context.go('/');
              } else if (i == 1) {
                _rememberRoute('/profile');
                context.go('/profile');
              } else if (i == 3) {
                _rememberRoute('/cart');
                context.go('/cart');
              }
            },
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Account',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: 'Wallet',
              ),
              NavigationDestination(
                icon: Consumer<CartProvider>(
                  builder: (_, provider, _) => Badge(
                    label: Text(
                      '${provider.cart.items.fold<int>(0, (sum, item) => sum + item.quantity)}',
                    ),
                    isLabelVisible: provider.cart.items.isNotEmpty,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
                selectedIcon: const Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              const NavigationDestination(
                icon: Icon(Icons.menu),
                selectedIcon: Icon(Icons.menu_open),
                label: 'Browse',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openWallet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _WalletSheet(),
    );
  }

  void _openBrowse() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      transitionAnimationController: null,
      backgroundColor: Colors.transparent,
      builder: (_) => const BrowsePage(),
    );
  }
}

class _WalletSheet extends StatelessWidget {
  const _WalletSheet();

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: .9,
    child: Material(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Smart Wallet',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _walletCard('Balance', '₹0', Icons.account_balance_wallet),
                    _walletCard('Cards', 'Manage', Icons.credit_card),
                    _walletCard('Pay Later', 'Check', Icons.schedule),
                  ],
                ),
                const SizedBox(height: 14),
                Card(
                  color: Colors.blue.shade50,
                  child: const ListTile(
                    leading: Icon(Icons.send, color: Colors.blue),
                    title: Text(
                      'Send Money',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text('Fast, safe and convenient payments'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ),
                const SizedBox(height: 12),
                const DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Reminders'),
                          Tab(text: 'Recommendations'),
                          Tab(text: 'People'),
                        ],
                      ),
                      SizedBox(
                        height: 48,
                        child: TabBarView(
                          children: [
                            Center(child: Text('No reminders')),
                            Center(child: Text('Offers and rewards')),
                            Center(child: Text('Pay your contacts')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    _QuickAction(Icons.link, 'Link'),
                    _QuickAction(Icons.person_add, 'Pay'),
                    _QuickAction(Icons.qr_code_scanner, 'Scan'),
                    _QuickAction(Icons.phone_android, 'Recharge'),
                    _QuickAction(Icons.receipt_long, 'Bills'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _walletCard(String title, String value, IconData icon) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange.shade800),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(value, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () =>
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$label action opened'))),
    child: Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    ),
  );
}

class _BrowseHub extends StatefulWidget {
  const _BrowseHub();
  @override
  State<_BrowseHub> createState() => _BrowseHubState();
}

class _BrowseHubState extends State<_BrowseHub> {
  int selected = 0;
  final categories = const [
    'Top Picks',
    'Mobiles',
    'Electronics',
    'Fashion',
    'Home',
    'Grocery',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Browse'),
      actions: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 118,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (_, index) => ListTile(
                    selected: selected == index,
                    selectedTileColor: Colors.blue.shade50,
                    title: Text(categories[index]),
                    onTap: () => setState(() => selected = index),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: GridView.builder(
                    key: ValueKey(selected),
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.25,
                        ),
                    itemCount: 6,
                    itemBuilder: (_, index) => Card(
                      child: Center(
                        child: Text(
                          '${categories[selected]}\n${index + 1}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _footerAction(context, Icons.receipt_long, 'Orders', '/orders'),
              _footerAction(context, Icons.replay, 'Buy Again', '/orders'),
              _footerAction(context, Icons.person, 'Account', '/profile'),
              _footerAction(context, Icons.favorite, 'Wishlist', '/wishlist'),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _footerAction(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) => TextButton.icon(
    onPressed: () {
      context.pop();
      context.push(route);
    },
    icon: Icon(icon, size: 18),
    label: Text(label),
  );
}
