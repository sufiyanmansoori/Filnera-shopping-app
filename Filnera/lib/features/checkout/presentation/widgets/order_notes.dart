import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/checkout_provider.dart';

class OrderNotes extends StatelessWidget {
  const OrderNotes({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    final controller = TextEditingController(text: provider.notes);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        onChanged: provider.setNotes,
        decoration: const InputDecoration(
          labelText: 'Order notes',
          border: OutlineInputBorder(),
          hintText: 'Any special delivery instructions?',
        ),
      ),
    );
  }
}
