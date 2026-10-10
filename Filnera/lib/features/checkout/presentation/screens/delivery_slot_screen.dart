import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/delivery_slot_provider.dart';

class DeliverySlotScreen extends StatefulWidget {
  const DeliverySlotScreen({super.key});

  @override
  State<DeliverySlotScreen> createState() => _DeliverySlotScreenState();
}

class _DeliverySlotScreenState extends State<DeliverySlotScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliverySlotProvider>().loadSlots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose delivery slot')),
      body: Consumer<DeliverySlotProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final slots = provider.slots;
          if (slots.isEmpty) {
            return const Center(child: Text('No delivery slots available'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: slots.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final slot = slots[index];
              final selected = provider.selectedSlot?.id == slot.id;
              return Card(
                color: selected ? Colors.orange.shade50 : null,
                child: ListTile(
                  title: Text(slot.label),
                  subtitle: Text(
                    '${slot.date.day}/${slot.date.month}/${slot.date.year} • ${slot.startTime} - ${slot.endTime}',
                  ),
                  trailing: Text(
                    slot.price == 0
                        ? 'Free'
                        : '₹${slot.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () {
                    provider.selectSlot(slot);
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
