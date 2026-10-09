import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'How do I update my profile?',
        'answer': 'Open the profile screen and tap the edit button to update your personal information.',
      },
      {
        'question': 'Can I add multiple delivery addresses?',
        'answer': 'Yes, you can add and manage multiple addresses from the Address book section.',
      },
      {
        'question': 'What payment methods are supported?',
        'answer': 'The app supports UPI, wallets, cards, and secure digital payments through supported gateways.',
      },
      {
        'question': 'How do I contact support?',
        'answer': 'You can contact support via the in-app help desk or email us at support@manara.app.',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Help & support')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Frequently asked questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            ...faqs.map(
              (item) => Card(
                child: ExpansionTile(
                  title: Text(item['question'] as String),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(item['answer'] as String),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email us'),
              subtitle: const Text('support@manara.app'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                // Can be wired to launch mail app later.
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Customer support'),
              subtitle: const Text('+91 80000 12345'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                // Can be wired to call support later.
              },
            ),
          ],
        ),
      ),
    );
  }
}
