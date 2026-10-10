import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _twoFactor = true;
  bool _biometric = true;
  bool _rememberDevices = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security & privacy')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Protect your account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Two-step verification'),
              subtitle: const Text('Add an extra layer of login protection.'),
              value: _twoFactor,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _twoFactor = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Face ID / fingerprint'),
              subtitle: const Text('Use device biometrics for quick access.'),
              value: _biometric,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _biometric = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Remember trusted devices'),
              subtitle: const Text(
                'Keep trusted devices signed in for convenience.',
              ),
              value: _rememberDevices,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _rememberDevices = value),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline_rounded),
              title: const Text('Change password'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password update flow coming soon.'),
                  ),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.devices_other_outlined),
              title: const Text('Manage devices'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Device management flow coming soon.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
