import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/order_timeline_widget.dart';
import '../widgets/order_status_widget.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.selectedOrder == null) {
            return const Center(child: Text('Order not found'));
          }

          final order = provider.selectedOrder!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OrderStatusWidget(status: order.status),
              const SizedBox(height: 12),
              Text(
                'Order ${order.id}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Created: ${order.createdAt.toLocal().toString()}'),
              const SizedBox(height: 14),
              Text('Shipping: ${order.shippingAddress}'),
              const SizedBox(height: 14),
              const OrderTimelineWidget(
                timeline: ['Packed', 'Shipped', 'Out for delivery'],
              ),
            ],
          );
        },
      ),
    );
  }
}
