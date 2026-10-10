import 'package:flutter/material.dart';

import '../../data/models/delivery_slot_model.dart';

class DeliverySlotSelectorCard extends StatelessWidget {
  const DeliverySlotSelectorCard({super.key, required this.slot});

  final DeliverySlotModel slot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${slot.date.day}/${slot.date.month}/${slot.date.year} • ${slot.startTime} - ${slot.endTime}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            slot.price == 0 ? 'Free' : '₹${slot.price.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
