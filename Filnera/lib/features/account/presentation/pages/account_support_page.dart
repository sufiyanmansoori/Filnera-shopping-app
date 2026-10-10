import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum AccountSupportSection { business, faqs, policies }

class AccountSupportPage extends StatefulWidget {
  const AccountSupportPage({super.key, required this.section});

  final AccountSupportSection section;

  @override
  State<AccountSupportPage> createState() => _AccountSupportPageState();
}

class _AccountSupportPageState extends State<AccountSupportPage> {
  final _search = TextEditingController();
  String _query = '';

  static const _faqs = [
    (
      'How do I track my order?',
      'Open My Orders, select an order, and tap Track order.',
    ),
    (
      'What payment methods are supported?',
      'UPI, cards, wallets, net banking and Cash on Delivery are supported.',
    ),
    (
      'How do I request a return?',
      'Open the delivered order and select Return or Replace.',
    ),
    (
      'What should I do if payment fails?',
      'Check your bank status, retry once, or choose another payment method.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _search.addListener(
      () => setState(() => _query = _search.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.section) {
      AccountSupportSection.business => 'Business, Selling & Verification',
      AccountSupportSection.faqs => 'Frequently Asked Questions',
      AccountSupportSection.policies => 'Terms, Policies & Licences',
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: switch (widget.section) {
        AccountSupportSection.business => _business(),
        AccountSupportSection.faqs => _faq(),
        AccountSupportSection.policies => _policies(),
      },
    );
  }

  Widget _business() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _action(
        Icons.campaign_outlined,
        'Manara Affiliate Program',
        'Share products and earn rewards',
        () => _message('Affiliate registration opened'),
      ),
      _action(
        Icons.inventory_2_outlined,
        'Bulk Purchasing (B2B)',
        'Wholesale pricing and GST invoices',
        () => _message('B2B enquiry form opened'),
      ),
      _action(
        Icons.storefront_outlined,
        'Sell on Manara',
        'Start selling and manage your store',
        () => _message('Seller registration opened'),
      ),
    ],
  );

  Widget _faq() {
    final results = _faqs
        .where((item) => item.$1.toLowerCase().contains(_query))
        .toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _search,
          decoration: const InputDecoration(
            hintText: 'Search questions',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ...results.map(
          (item) => Card(
            child: ExpansionTile(
              title: Text(item.$1),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(item.$2),
                ),
              ],
            ),
          ),
        ),
        if (results.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No matching questions found'),
            ),
          ),
      ],
    );
  }

  Widget _policies() => ListView(
    padding: const EdgeInsets.all(16),
    children: const [
      Text(
        'Terms of Use',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      SizedBox(height: 8),
      Text(
        'By using Manara Store, you agree to our shopping, payment and account terms.',
      ),
      SizedBox(height: 20),
      Text(
        'Privacy Policy',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      SizedBox(height: 8),
      Text(
        'Your account and order information is used to provide delivery, support and secure checkout.',
      ),
      SizedBox(height: 20),
      Text(
        'Returns and Refunds',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      SizedBox(height: 8),
      Text(
        'Return eligibility, pickup and refund timing are shown on each order.',
      ),
    ],
  );

  Widget _action(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => Card(
    child: ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}

Future<void> openSocialLink(
  BuildContext context,
  String label,
  String url,
) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Unable to open $label')));
  }
}
