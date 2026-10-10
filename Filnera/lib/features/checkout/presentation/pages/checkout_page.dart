import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../address/data/address_store.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';

enum PaymentMethod { card, upi, wallet, cod }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

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
    const deliveryFee = 149.0;
    const subtotal = 6499.0;
    const total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Place order'),
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
