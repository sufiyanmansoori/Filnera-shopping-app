import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/saved_payment_card.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentMethods =
        <({String title, String brand, String lastFour, String? expiry})>[
          (title: 'UPI', brand: 'UPI', lastFour: '1234', expiry: null),
          (
            title: 'Bank account',
            brand: 'HDFC',
            lastFour: '9812',
            expiry: 'Visa',
          ),
          (title: 'Wallet', brand: 'Paytm', lastFour: '0005', expiry: 'Wallet'),
        ];

    return Scaffold(
      appBar: AppBar(title: const Text('Payment methods')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Choose a payment method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            ...paymentMethods.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SavedPaymentCard(
                  title: method.title,
                  brand: method.brand,
                  lastFour: method.lastFour,
                  expiry: method.expiry,
                  isPrimary: index == 0,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${method.title} selected')),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Secure and fast checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All payments are processed through secure encrypted gateways. Your data is protected with 256-bit encryption.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
