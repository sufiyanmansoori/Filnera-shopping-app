import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/payment_summary_card.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    this.amount = 299.00,
    this.orderId = 'ORD-1001',
    this.currency = '₹',
  });

  final double amount;
  final String orderId;
  final String currency;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentProvider()..loadMethods(),
      child: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          final selectedMethod = provider.selectedMethod;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('Checkout payment')),
            body: SafeArea(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage != null && provider.methods.isEmpty
                  ? _buildErrorState(provider)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PaymentSummaryCard(
                            amount: widget.amount,
                            orderId: widget.orderId,
                            currency: widget.currency,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Select a payment method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (provider.errorMessage != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                provider.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ...provider.methods.map(
                            (method) => PaymentMethodCard(
                              method: method,
                              isSelected: selectedMethod?.id == method.id,
                              onTap: () => provider.selectMethod(method),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  provider.isProcessing ||
                                      selectedMethod == null
                                  ? null
                                  : () async {
                                      final transaction = await provider
                                          .confirmPayment(
                                            amount: widget.amount,
                                            orderId: widget.orderId,
                                            currency: 'INR',
                                          );

                                      if (!mounted || transaction == null) {
                                        return;
                                      }

                                      if (!context.mounted) {
                                        return;
                                      }

                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => PaymentSuccessScreen(
                                            transaction: transaction,
                                          ),
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: provider.isProcessing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Pay Now'),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(PaymentProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => provider.loadMethods(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
