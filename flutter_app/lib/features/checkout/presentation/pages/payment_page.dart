import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';

enum CheckoutPaymentMethod { upi, card, wallet, cod, giftCard, emi }

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  CheckoutPaymentMethod? _expanded;
  bool _amountExpanded = false;
  bool _processing = false;
  final _giftCard = TextEditingController();

  @override
  void dispose() {
    _giftCard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step 3 of 3', style: TextStyle(fontSize: 12)),
              Text('Payments'),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16),
                  SizedBox(width: 4),
                  Text('100% Secure', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _amountBanner(),
              const SizedBox(height: 12),
              _cashbackBanner(),
              const SizedBox(height: 20),
              const Text(
                'Recommended for You',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              _methodCard(
                CheckoutPaymentMethod.upi,
                Icons.account_balance_wallet,
                'UPI',
                'Pay using any UPI app',
                'Up to ₹100 cashback',
              ),
              _methodCard(
                CheckoutPaymentMethod.cod,
                Icons.payments_outlined,
                'Cash on Delivery',
                'Pay when your order arrives',
                null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Other Payment Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              _methodCard(
                CheckoutPaymentMethod.card,
                Icons.credit_card,
                'Credit / Debit / ATM Card',
                'Add and secure cards for faster checkout',
                null,
              ),
              _methodCard(
                CheckoutPaymentMethod.wallet,
                Icons.account_balance_wallet_outlined,
                'Wallets',
                'Paytm and other wallets',
                'Extra cashback available',
              ),
              _methodCard(
                CheckoutPaymentMethod.giftCard,
                Icons.card_giftcard,
                'Gift Card',
                'Use a saved gift card balance',
                null,
              ),
              _methodCard(
                CheckoutPaymentMethod.emi,
                Icons.calendar_month,
                'EMI',
                'Not available for this order',
                null,
                disabled: true,
              ),
              const SizedBox(height: 12),
              const Text(
                'Test mode is enabled. Connect a verified payment gateway before production.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ]),
          ),
        ),
      ],
    ),
  );

  Widget _amountBanner() => Card(
    color: const Color(0xFFE8F0FE),
    child: Column(
      children: [
        ListTile(
          title: const Text(
            'Total Amount',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppFormatters.currency(289),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Icon(_amountExpanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
          onTap: () => setState(() => _amountExpanded = !_amountExpanded),
        ),
        if (_amountExpanded) ...[
          _summary('MRP', '₹399'),
          _summary('Discount', '-₹110', color: Colors.green),
          _summary('Tax and fees', '₹0'),
        ],
      ],
    ),
  );

  Widget _cashbackBanner() => Card(
    color: const Color(0xFFE8F5E9),
    child: ListTile(
      leading: const Icon(Icons.local_offer, color: Colors.green),
      title: const Text(
        '5% Cashback',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: const Text('Claim now with online payment'),
      trailing: SizedBox(
        width: 72,
        child: Stack(
          children: [
            _avatar('P', Colors.blue),
            Positioned(left: 18, child: _avatar('G', Colors.green)),
            const Positioned(
              left: 38,
              top: 12,
              child: Text('+3', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _methodCard(
    CheckoutPaymentMethod method,
    IconData icon,
    String title,
    String subtitle,
    String? offer, {
    bool disabled = false,
  }) {
    final selected = _expanded == method;
    return Semantics(
      button: !disabled,
      label: '$title payment method${disabled ? ', unavailable' : ''}',
      child: Card(
        color: disabled
            ? Colors.grey.shade100
            : selected
            ? AppColors.primary.withValues(alpha: .06)
            : Colors.white,
        child: Column(
          children: [
            ListTile(
              enabled: !disabled,
              leading: CircleAvatar(
                backgroundColor: disabled
                    ? Colors.grey.shade200
                    : Colors.blue.shade50,
                child: Icon(
                  icon,
                  color: disabled ? Colors.grey : AppColors.primary,
                ),
              ),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: Icon(selected ? Icons.expand_less : Icons.expand_more),
              onTap: disabled
                  ? null
                  : () => setState(() => _expanded = selected ? null : method),
            ),
            if (offer != null && !disabled)
              Padding(
                padding: const EdgeInsets.only(left: 72, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '🎁 $offer',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              child: selected
                  ? _expandedContent(method)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expandedContent(CheckoutPaymentMethod method) {
    if (method == CheckoutPaymentMethod.cod) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            const Text(
              'A nominal ₹10 handling fee will be charged for Cash on Delivery.',
              style: TextStyle(color: Colors.deepOrange),
            ),
            const SizedBox(height: 10),
            _orderButton('Place Order', () => _placeOrder('Cash on Delivery')),
          ],
        ),
      );
    }
    if (method == CheckoutPaymentMethod.giftCard) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: TextField(
          controller: _giftCard,
          decoration: InputDecoration(
            labelText: 'Have a Flipkart Gift Card?',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _message('Gift card code applied'),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: _orderButton(
        'Continue securely',
        () => _placeOrder(_label(method)),
      ),
    );
  }

  Widget _orderButton(String label, VoidCallback action) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _processing ? null : action,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF9F00),
        foregroundColor: Colors.white,
      ),
      child: Text(_processing ? 'Processing...' : label),
    ),
  );

  Widget _summary(String label, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: TextStyle(color: color)),
      ],
    ),
  );

  Widget _avatar(String text, Color color) => CircleAvatar(
    radius: 15,
    backgroundColor: color,
    child: Text(text, style: const TextStyle(color: Colors.white)),
  );

  String _label(CheckoutPaymentMethod method) => switch (method) {
    CheckoutPaymentMethod.upi => 'UPI',
    CheckoutPaymentMethod.card => 'Card',
    CheckoutPaymentMethod.wallet => 'Wallet',
    CheckoutPaymentMethod.cod => 'Cash on Delivery',
    CheckoutPaymentMethod.giftCard => 'Gift Card',
    CheckoutPaymentMethod.emi => 'EMI',
  };

  Future<void> _placeOrder(String method) async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _processing = false);
    _showSuccess('Order placed using $method');
  }

  void _showSuccess(String message) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 52),
      title: const Text('Order confirmed'),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => dialogContext.go('/orders'),
          child: const Text('View orders'),
        ),
      ],
    ),
  );

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}
