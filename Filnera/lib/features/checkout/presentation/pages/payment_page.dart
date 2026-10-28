import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../data/checkout_intent_store.dart';

enum CheckoutPaymentMethod { upi, card, wallet, cod, giftCard, emi }

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, this.buyNow = false});

  final bool buyNow;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  CheckoutPaymentMethod? _expanded;
  bool _amountExpanded = false;
  final _giftCard = TextEditingController();

  @override
  void dispose() {
    _giftCard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    final buyNowItem = widget.buyNow ? CheckoutIntentStore.buyNowItem : null;
    final subtotal = buyNowItem?.subtotal ?? cart.subtotal;
    final discount = widget.buyNow ? 0.0 : cart.discount;
    final total = subtotal - discount + cart.deliveryFee;
    return Scaffold(
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
                    Text('Payment setup', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _amountBanner(subtotal, discount, total),
                const SizedBox(height: 12),
                _paymentStatusBanner(),
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
                  disabled: true,
                ),
                _methodCard(
                  CheckoutPaymentMethod.cod,
                  Icons.payments_outlined,
                  'Cash on Delivery',
                  'Pay when your order arrives',
                  null,
                  disabled: true,
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
                  disabled: true,
                ),
                _methodCard(
                  CheckoutPaymentMethod.wallet,
                  Icons.account_balance_wallet_outlined,
                  'Wallets',
                  'Paytm and other wallets',
                  'Extra cashback available',
                  disabled: true,
                ),
                _methodCard(
                  CheckoutPaymentMethod.giftCard,
                  Icons.card_giftcard,
                  'Gift Card',
                  'Use a saved gift card balance',
                  null,
                  disabled: true,
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
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountBanner(double subtotal, double discount, double total) => Card(
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
                AppFormatters.currency(total),
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
          _summary('Subtotal', AppFormatters.currency(subtotal)),
          _summary(
            'Discount',
            '-${AppFormatters.currency(discount)}',
            color: Colors.green,
          ),
          _summary('Delivery and fees', '₹0'),
        ],
      ],
    ),
  );

  Widget _paymentStatusBanner() => const Card(
    color: Color(0xFFFFF4E5),
    child: ListTile(
      leading: Icon(Icons.info_outline, color: Colors.deepOrange),
      title: Text('Payments are not configured'),
      subtitle: Text(
        'A verified payment gateway and order API are required before '
        'orders can be placed. No payment will be collected here.',
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
      onPressed: action,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF9F00),
        foregroundColor: Colors.white,
      ),
      child: Text(label),
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

  String _label(CheckoutPaymentMethod method) => switch (method) {
    CheckoutPaymentMethod.upi => 'UPI',
    CheckoutPaymentMethod.card => 'Card',
    CheckoutPaymentMethod.wallet => 'Wallet',
    CheckoutPaymentMethod.cod => 'Cash on Delivery',
    CheckoutPaymentMethod.giftCard => 'Gift Card',
    CheckoutPaymentMethod.emi => 'EMI',
  };

  void _placeOrder(String _) => _message(
    'Order placement is unavailable until a payment gateway is configured.',
  );

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}
