import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/payment_provider.dart';
import '../widgets/payment_method_widget.dart';
import '../widgets/proceed_button_widget.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const PaymentMethodWidget(method: 'Card'),
                const SizedBox(height: 16),
                ProceedButtonWidget(
                  label: 'Pay Now',
                  onPressed: () => provider.pay(amount: 500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
