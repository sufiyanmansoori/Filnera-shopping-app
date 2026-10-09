import 'package:flutter/material.dart';

class SavedPaymentsPage extends StatelessWidget {
  const SavedPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Saved payment methods')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _method(Icons.account_balance_wallet_outlined, 'UPI', 'manara@upi'),
        _method(
          Icons.credit_card_outlined,
          'Credit card',
          'Visa ending in 4242',
        ),
        _method(Icons.account_balance_outlined, 'Net banking', 'HDFC Bank'),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _message(context, 'Add payment method opened'),
          icon: const Icon(Icons.add),
          label: const Text('Add payment method'),
        ),
        const SizedBox(height: 12),
        const Text(
          'For your security, complete payment numbers are never displayed.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );

  Widget _method(IconData icon, String title, String subtitle) => Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, color: Colors.blue.shade800),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    ),
  );

  void _message(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}

class PrivacyCenterPage extends StatelessWidget {
  const PrivacyCenterPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacy center')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.shield_outlined, size: 56, color: Colors.blue),
        const SizedBox(height: 12),
        const Text(
          'Your privacy choices',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Control how your account data is used for shopping, support and relevant offers.',
        ),
        SwitchListTile(
          value: true,
          onChanged: (_) {},
          title: const Text('Personalised offers'),
          subtitle: const Text(
            'Use shopping activity to improve recommendations',
          ),
        ),
        SwitchListTile(
          value: true,
          onChanged: (_) {},
          title: const Text('Usage analytics'),
          subtitle: const Text('Help improve app performance'),
        ),
        ListTile(
          leading: const Icon(Icons.policy_outlined),
          title: const Text('Privacy policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    ),
  );
}

class ManageDevicesPage extends StatelessWidget {
  const ManageDevicesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Manage devices')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '3 active devices',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text('Review devices signed in to your Manara account.'),
        _device(
          context,
          Icons.phone_android,
          'Android phone',
          'This device · Active now',
          true,
        ),
        _device(
          context,
          Icons.laptop_outlined,
          'Windows laptop',
          'Last active today',
          false,
        ),
        _device(
          context,
          Icons.tablet_android_outlined,
          'Android tablet',
          'Last active yesterday',
          false,
        ),
      ],
    ),
  );

  Widget _device(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool current,
  ) => Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, color: Colors.blue.shade800),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: current
          ? const Chip(label: Text('Current'))
          : TextButton(
              onPressed: () => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('$title signed out'))),
              child: const Text('Sign out'),
            ),
    ),
  );
}
