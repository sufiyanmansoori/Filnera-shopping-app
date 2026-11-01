import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/index.dart';
import 'core/services/theme_service.dart';
import 'core/theme/filnera_theme.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/presentation/providers/product_provider.dart';

class FilneraApp extends StatefulWidget {
  const FilneraApp({super.key});

  @override
  State<FilneraApp> createState() => _FilneraAppState();
}

class _FilneraAppState extends State<FilneraApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late final AuthProvider _authProvider;
  late final CartProvider _cartProvider;

  @override
  void initState() {
    super.initState();
    _themeMode = ThemePreferenceService.initialMode;
    _authProvider = AuthProvider();
    _cartProvider = CartProvider(repository: CartRepositoryImpl());
    _authProvider.loadSession().then((_) {
      final user = _authProvider.currentUser;
      if (mounted && user != null && _authProvider.isAuthenticated) {
        _cartProvider.fetchCart(user.userId);
      }
    });
    ThemePreferenceService.themeMode.addListener(_themeChanged);
  }

  @override
  void dispose() {
    ThemePreferenceService.themeMode.removeListener(_themeChanged);
    _authProvider.dispose();
    _cartProvider.dispose();
    super.dispose();
  }

  void _themeChanged() {
    if (!mounted) return;
    setState(() => _themeMode = ThemePreferenceService.themeMode.value);
  }

  @override
  Widget build(BuildContext context) {
    final light = FilneraTheme.lightTheme();
    final dark = FilneraTheme.darkTheme();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _cartProvider),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(repository: ProductRepositoryImpl()),
        ),
      ],
      child: AnimatedTheme(
        data: _themeMode == ThemeMode.dark ? dark : light,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
        child: MaterialApp.router(
          title: 'Filnera Store',
          debugShowCheckedModeBanner: false,
          theme: light,
          darkTheme: dark,
          themeMode: _themeMode,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
