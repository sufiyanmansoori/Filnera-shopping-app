import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  bool _push = true;
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _securityAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Push notifications'),
              subtitle: const Text(
                'Receive updates and reminders on your device.',
              ),
              value: _push,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _push = value),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Order updates'),
              subtitle: const Text(
                'Track status changes and delivery notifications.',
              ),
              value: _orderUpdates,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _orderUpdates = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Promotions & deals'),
              subtitle: const Text(
                'Get product recommendations and exclusive offers.',
              ),
              value: _promotions,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _promotions = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Security alerts'),
              subtitle: const Text('Login and account activity notifications.'),
              value: _securityAlerts,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _securityAlerts = value),
            ),
          ],
        ),
      ),
    );
  }
}
