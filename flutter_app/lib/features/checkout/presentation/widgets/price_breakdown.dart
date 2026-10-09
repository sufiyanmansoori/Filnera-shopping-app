import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/checkout_provider.dart';

class PriceBreakdown extends StatelessWidget {
  const PriceBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    final checkout = context.watch<CheckoutProvider>();
    final subtotal = checkout.items.fold<double>(0, (sum, item) {
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
      final quantity = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
      return sum + (price * quantity);
    });
    final deliveryFee = checkout.selectedSlot?.price ?? 0;
    final total = subtotal + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('₹${subtotal.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery'),
              Text('₹${deliveryFee.toStringAsFixed(0)}'),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                '₹${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
