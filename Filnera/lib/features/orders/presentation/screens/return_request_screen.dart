import 'package:flutter/material.dart';

import 'order_return_screen.dart';

class ReturnRequestScreen extends StatelessWidget {
  const ReturnRequestScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return OrderReturnScreen(orderId: orderId);
  }
}
