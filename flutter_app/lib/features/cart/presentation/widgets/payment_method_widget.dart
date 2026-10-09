import 'package:flutter/material.dart';

class PaymentMethodWidget extends StatelessWidget {
  const PaymentMethodWidget({super.key, required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.payment_outlined),
        title: const Text('Payment Method'),
        subtitle: Text(method.toUpperCase()),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
      ),
    );
  }
}
