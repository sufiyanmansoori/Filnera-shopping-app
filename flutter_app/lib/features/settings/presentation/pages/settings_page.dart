import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/theme_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool orderUpdates = true;
  ThemeMode _selectedMode = ThemePreferenceService.initialMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'PREFERENCES',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('Push notifications'),
              subtitle: const Text('Deals, orders and recommendations'),
              value: notifications,
              onChanged: (value) => setState(() => notifications = value),
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('Order updates'),
              subtitle: const Text('Shipping and delivery alerts'),
              value: orderUpdates,
              onChanged: (value) => setState(() => orderUpdates = value),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('System'),
                        selected: _selectedMode == ThemeMode.system,
                        onSelected: (_) => _applyTheme(ThemeMode.system),
                      ),
                      ChoiceChip(
                        label: const Text('Light'),
                        selected: _selectedMode == ThemeMode.light,
                        onSelected: (_) => _applyTheme(ThemeMode.light),
                      ),
                      ChoiceChip(
                        label: const Text('Dark'),
                        selected: _selectedMode == ThemeMode.dark,
                        onSelected: (_) => _applyTheme(ThemeMode.dark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'ACCOUNT',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Manage addresses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/location'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Privacy and security'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showInfo(
                    context,
                    'Privacy and security',
                    'Your account and payment details are protected.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help centre'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showInfo(
                    context,
                    'Help centre',
                    'Chat support is available for orders, payments and returns.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyTheme(ThemeMode mode) async {
    await ThemePreferenceService.saveMode(mode);
    if (!mounted) return;

    setState(() => _selectedMode = mode);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Theme set to ${mode.name}')));
  }

  void _showInfo(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }
}
