import 'package:flutter/material.dart';

import 'order_detail_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return OrderDetailScreen(orderId: orderId);
  }
}
