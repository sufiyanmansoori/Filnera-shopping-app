import 'package:flutter/material.dart';
import 'package:filnera/features/account/presentation/screens/gift_cards_page.dart';
import 'package:go_router/go_router.dart';
import '../core/services/session_service.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/checkout/presentation/pages/checkout_page.dart';
import '../features/navigation/presentation/pages/main_shell.dart';
import '../features/products/presentation/screens/product_detail_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/search/presentation/pages/search_page.dart';
import '../features/wishlist/presentation/pages/wishlist_page.dart';
import '../features/shop/presentation/pages/shop_pages.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/orders/presentation/pages/orders_page.dart';
import '../features/admin/presentation/pages/admin_panel_page.dart';
import '../features/admin/presentation/pages/admin_catalog_manager_page.dart';
import '../features/checkout/presentation/pages/payment_page.dart';
import '../features/address/presentation/pages/address_page.dart';
import '../features/account/presentation/pages/account_support_page.dart';
import '../features/account/presentation/pages/account_extras_page.dart';
import '../features/account/presentation/pages/account_security_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/admin/presentation/pages/add_product_image_page.dart';
import '../features/payments/presentation/pages/scan_and_pay_screen.dart';
import '../features/browse/presentation/pages/browse_page.dart';

class AppRouter {
  static final _authRefresh = _SessionRefreshListenable();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _authRefresh,
    redirect: (context, state) {
      const protectedLocations = {
        '/cart',
        '/checkout',
        '/payment',
        '/addresses',
        '/orders',
      };
      if (protectedLocations.contains(state.uri.path) &&
          !SessionService.isAuthenticated.value) {
        return '/login?returnTo=${Uri.encodeComponent(state.uri.toString())}';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/search',
            builder: (context, state) =>
                SearchPage(initialQuery: state.uri.queryParameters['q'] ?? ''),
          ),
          GoRoute(
            path: '/wishlist',
            builder: (context, state) => const WishlistPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/checkout',
            builder: (context, state) => CheckoutPage(
              buyNow: state.uri.queryParameters['buyNow'] == 'true',
            ),
          ),
          GoRoute(
            path: '/payment',
            builder: (context, state) => PaymentPage(
              buyNow: state.uri.queryParameters['buyNow'] == 'true',
            ),
          ),
          GoRoute(
            path: '/addresses',
            builder: (context, state) => const AddressPage(),
          ),
          GoRoute(
            path: '/account/:section',
            builder: (context, state) {
              final section = switch (state.pathParameters['section']) {
                'business' => AccountSupportSection.business,
                'faqs' => AccountSupportSection.faqs,
                _ => AccountSupportSection.policies,
              };
              return AccountSupportPage(section: section);
            },
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (context, state) => const EditProfilePage(),
          ),
          GoRoute(
            path: '/gift-cards',
            builder: (context, state) => const GiftCardsPage(),
          ),
          GoRoute(
            path: '/saved-payments',
            builder: (context, state) => const SavedPaymentsPage(),
          ),
          GoRoute(
            path: '/privacy-center',
            builder: (context, state) => const PrivacyCenterPage(),
          ),
          GoRoute(
            path: '/manage-devices',
            builder: (context, state) => const ManageDevicesPage(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => LoginPage(
              returnTo: state.uri.queryParameters['returnTo'],
            ),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => RegisterPage(
              returnTo: state.uri.queryParameters['returnTo'],
            ),
          ),
          GoRoute(
            path: '/location',
            builder: (context, state) => const LocationPage(),
          ),
          GoRoute(
            path: '/filters',
            builder: (context, state) => const FiltersPage(),
          ),
          GoRoute(path: '/play', builder: (context, state) => const PlayPage()),
          GoRoute(
            path: '/deals',
            builder: (context, state) => const DealsPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersPage(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: '/order/:id',
            builder: (context, state) =>
                OrderDetailsPage(orderId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminPanelPage(),
          ),
          GoRoute(
            path: '/admin/catalog',
            builder: (context, state) => const AdminCatalogManagerPage(),
          ),
          GoRoute(
            path: '/add-product-image',
            builder: (context, state) => const AddProductImagePage(),
          ),
          GoRoute(
            path: '/scan-and-pay',
            builder: (context, state) => const ScanAndPayScreen(),
          ),
          GoRoute(
            path: '/browse',
            builder: (context, state) => const BrowsePage(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductListScreen(),
          ),
          GoRoute(
            path: '/product/:id',
            builder: (context, state) => ProductDetailScreen(
              productId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
    ],
  );

  static void goToProduct(BuildContext context, ProductModel product) {
    context.push('/product/${product.id}');
  }
}

class _SessionRefreshListenable extends ChangeNotifier {
  _SessionRefreshListenable() {
    SessionService.isAuthenticated.addListener(notifyListeners);
  }
}

class ProductModel {
  Null get id => null;
}
