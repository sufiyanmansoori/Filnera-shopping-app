import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../address/data/address_store.dart';
import '../../../cart/data/models/cart_model.dart';
import '../../../cart/data/models/cart_item_model.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../data/checkout_intent_store.dart';

enum PaymentMethod { card, upi, wallet, cod }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, this.buyNow = false});

  final bool buyNow;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod _selectedPayment = PaymentMethod.card;

  @override
  void initState() {
    super.initState();
    AddressStore.load();
  }

  @override
  Widget build(BuildContext context) {
    final providerCart = context.watch<CartProvider>().cart;
    final buyNowItem = widget.buyNow ? CheckoutIntentStore.buyNowItem : null;
    if (!widget.buyNow) CheckoutIntentStore.clear();
    final items = buyNowItem == null
        ? const <CartItemModel>[]
        : <CartItemModel>[buyNowItem];
    final effectiveCart = widget.buyNow
        ? CartModel(
            items: items,
            couponCode: '',
            discount: 0,
            deliveryFee: providerCart.deliveryFee,
          )
        : providerCart;
    final subtotal = effectiveCart.subtotal;
    final deliveryFee = effectiveCart.deliveryFee;
    final total = effectiveCart.total;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (effectiveCart.items.isNotEmpty) ...[
              const Text(
                'Items in this order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...effectiveCart.items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.productName),
                  subtitle: Text('Qty ${item.quantity}'),
                  trailing: Text(AppFormatters.currency(item.subtotal)),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Shipping address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<DeliveryAddress?>(
              valueListenable: AddressStore.selected,
              builder: (context, address, _) => Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(address?.name ?? 'No address selected'),
                  subtitle: Text(
                    address?.formatted ?? 'Add a delivery address to continue',
                  ),
                  trailing: TextButton(
                    onPressed: () => context.push('/addresses'),
                    child: Text(address == null ? 'Add' : 'Change'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Payment method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            RadioGroup<PaymentMethod>(
              groupValue: _selectedPayment,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPayment = value);
                }
              },
              child: Column(
                children: PaymentMethod.values.map((method) {
                  final isSelected = _selectedPayment == method;
                  final label = switch (method) {
                    PaymentMethod.card => 'Credit / Debit Card',
                    PaymentMethod.upi => 'UPI',
                    PaymentMethod.wallet => 'Digital Wallet',
                    PaymentMethod.cod => 'Cash on Delivery',
                  };

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => setState(() => _selectedPayment = method),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Radio<PaymentMethod>(value: method),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    switch (method) {
                                      PaymentMethod.card =>
                                        'Visa, Mastercard, Amex',
                                      PaymentMethod.upi =>
                                        'Paytm, GPay, PhonePe',
                                      PaymentMethod.wallet =>
                                        'EasyPaisa, JazzCash',
                                      PaymentMethod.cod => 'Pay at delivery',
                                    },
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _summaryRow('Subtotal', AppFormatters.currency(subtotal)),
                  _summaryRow('Delivery', AppFormatters.currency(deliveryFee)),
                  if (effectiveCart.discount > 0)
                    _summaryRow(
                      'Discount',
                      '-${AppFormatters.currency(effectiveCart.discount)}',
                    ),
                  const Divider(height: 20),
                  _summaryRow(
                    'Total',
                    AppFormatters.currency(total),
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<DeliveryAddress?>(
              valueListenable: AddressStore.selected,
              builder: (context, address, _) => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: effectiveCart.items.isNotEmpty && address != null
                      ? () => context.push(
                          widget.buyNow ? '/payment?buyNow=true' : '/payment',
                        )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    effectiveCart.items.isEmpty
                        ? 'Your cart is empty'
                        : address == null
                        ? 'Add a shipping address'
                        : 'Continue to payment',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
