import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';

class OrderCardWidget extends StatelessWidget {
  const OrderCardWidget({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text('Order ${order.id}'),
        subtitle: Text(
          '${order.status.toUpperCase()} • ${order.items.length} items',
        ),
        trailing: Text('₹${order.total.toStringAsFixed(2)}'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Order Details')),
                body: Center(child: Text('Order ${order.id}')),
              ),
            ),
          );
        },
      ),
    );
  }
}
