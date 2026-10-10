import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/address_provider.dart';
import '../providers/checkout_provider.dart';
import '../providers/delivery_slot_provider.dart';
import '../widgets/address_selection.dart';
import '../widgets/checkout_steps.dart';
import '../widgets/delivery_slot_selector.dart';
import '../widgets/order_notes.dart';
import '../widgets/order_summary.dart';
import '../widgets/price_breakdown.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    this.items = const <Map<String, dynamic>>[],
  });

  final List<Map<String, dynamic>> items;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
      context.read<DeliverySlotProvider>().loadSlots();
      context.read<CheckoutProvider>().setItems(widget.items);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child:
            Consumer3<AddressProvider, DeliverySlotProvider, CheckoutProvider>(
              builder:
                  (
                    context,
                    addressProvider,
                    slotProvider,
                    checkoutProvider,
                    _,
                  ) {
                    final selectedAddress = addressProvider.selectedAddress;
                    final selectedSlot = slotProvider.selectedSlot;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CheckoutSteps(),
                          const SizedBox(height: 20),
                          const Text(
                            'Delivery address',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (selectedAddress != null)
                            AddressSelectionCard(address: selectedAddress)
                          else
                            const Text('No address selected'),
                          const SizedBox(height: 20),
                          const Text(
                            'Delivery slot',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (selectedSlot != null)
                            DeliverySlotSelectorCard(slot: selectedSlot)
                          else
                            const Text('No delivery slot selected'),
                          const SizedBox(height: 20),
                          const Text(
                            'Payment method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ChoiceChip(
                                label: const Text('Cash on delivery'),
                                selected:
                                    checkoutProvider.paymentMethod == 'cod',
                                onSelected: (_) =>
                                    checkoutProvider.setPaymentMethod('cod'),
                              ),
                              ChoiceChip(
                                label: const Text('UPI'),
                                selected:
                                    checkoutProvider.paymentMethod == 'upi',
                                onSelected: (_) =>
                                    checkoutProvider.setPaymentMethod('upi'),
                              ),
                              ChoiceChip(
                                label: const Text('Card'),
                                selected:
                                    checkoutProvider.paymentMethod == 'card',
                                onSelected: (_) =>
                                    checkoutProvider.setPaymentMethod('card'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const OrderNotes(),
                          const SizedBox(height: 20),
                          const PriceBreakdown(),
                          const SizedBox(height: 20),
                          OrderSummary(items: checkoutProvider.items),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                checkoutProvider.setSelectedAddress(
                                  selectedAddress,
                                );
                                checkoutProvider.setSelectedDeliverySlot(
                                  selectedSlot,
                                );
                                final navigator = Navigator.of(context);
                                await checkoutProvider.submitOrder();
                                if (!mounted) return;
                                if (checkoutProvider.checkout != null) {
                                  navigator.pushNamed('/order-review');
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size.fromHeight(54),
                              ),
                              child: checkoutProvider.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Place order'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
            ),
      ),
    );
  }
}
