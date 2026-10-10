import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/cart_model.dart';
import '../providers/checkout_provider.dart';
import '../widgets/checkout_stepper_widget.dart';
import '../widgets/delivery_address_widget.dart';
import '../widgets/delivery_slot_widget.dart';
import '../widgets/proceed_button_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.cart});

  final CartModel cart;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Consumer<CheckoutProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const CheckoutStepperWidget(step: 1),
                const SizedBox(height: 16),
                const DeliveryAddressWidget(address: 'Metro Street, Floor 4'),
                const SizedBox(height: 16),
                const DeliverySlotWidget(slot: 'Tomorrow, 10 AM - 1 PM'),
                const SizedBox(height: 16),
                ProceedButtonWidget(
                  label: 'Continue to Payment',
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
