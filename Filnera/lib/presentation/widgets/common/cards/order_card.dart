import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderNumber,
    required this.total,
    required this.status,
    this.onTap,
  });

  final String orderNumber;
  final String total;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(orderNumber),
        subtitle: Text(status),
        trailing: Text(total),
        onTap: onTap,
      ),
    );
  }
}
