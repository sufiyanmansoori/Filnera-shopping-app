import 'package:flutter/material.dart';

class DeliverySlotWidget extends StatelessWidget {
  const DeliverySlotWidget({super.key, required this.slot});

  final String slot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule_outlined),
        title: const Text('Delivery Slot'),
        subtitle: Text(slot),
        trailing: const Icon(Icons.keyboard_arrow_down_rounded),
      ),
    );
  }
}
