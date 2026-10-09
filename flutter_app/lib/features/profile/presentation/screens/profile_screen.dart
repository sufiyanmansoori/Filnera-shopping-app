import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/user_profile_model.dart';
import '../providers/address_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/index.dart';
import 'addresses_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'notification_preferences_screen.dart';
import 'payment_methods_screen.dart';
import 'saved_cards_screen.dart';
import 'security_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()..loadProfile()),
        ChangeNotifierProvider(
          create: (_) => AddressProvider()..loadAddresses(),
        ),
      ],
      child: const _ProfileScreenContent(),
    );
  }
}

class _ProfileScreenContent extends StatelessWidget {
  const _ProfileScreenContent();

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final profile = profileProvider.profile ?? UserProfileModel.empty();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Account'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            icon: const Icon(Icons.edit_note_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: profileProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(
                      profile: profile,
                      onEditTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (profileProvider.errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          profileProvider.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MenuItem(
                      icon: Icons.person_outline,
                      title: 'Personal information',
                      subtitle:
                          '${profile.fullName} • ${profile.phone.isEmpty ? 'Add mobile number' : profile.phone}',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Address book',
                      subtitle: addressProvider.addresses.isEmpty
                          ? 'No addresses saved'
                          : '${addressProvider.addresses.length} saved addresses',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddressesScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MenuItem(
                      icon: Icons.credit_card_rounded,
                      title: 'Payment methods',
                      subtitle: 'Manage cards, UPI and wallet settings',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PaymentMethodsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MenuItem(
                      icon: Icons.credit_score_outlined,
                      title: 'Saved cards',
                      subtitle: 'View and manage saved cards',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SavedCardsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Order updates and promotions',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationPreferencesScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MenuItem(
                      icon: Icons.security_outlined,
                      title: 'Security & privacy',
                      subtitle: 'Login, privacy and device controls',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SecuritySettingsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MenuItem(
                      icon: Icons.help_center_outlined,
                      title: 'Help & support',
                      subtitle: 'FAQs, support and policies',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Log out',
                      subtitle: 'Sign out of your account',
                      isDanger: true,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signed out successfully.')));
    }
  }
}
