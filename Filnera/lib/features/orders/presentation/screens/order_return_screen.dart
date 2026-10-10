import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/return_reason_widget.dart';

class OrderReturnScreen extends StatefulWidget {
  const OrderReturnScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderReturnScreen> createState() => _OrderReturnScreenState();
}

class _OrderReturnScreenState extends State<OrderReturnScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Return Order')),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ReturnReasonWidget(),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await provider.submitReturn(widget.orderId, 'Damaged item');
                },
                child: const Text('Submit Return Request'),
              ),
            ],
          );
        },
      ),
    );
  }
}
