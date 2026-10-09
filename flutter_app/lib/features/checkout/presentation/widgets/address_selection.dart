import 'package:flutter/material.dart';

import '../../data/models/address_model.dart';

class AddressSelectionCard extends StatelessWidget {
  const AddressSelectionCard({super.key, required this.address});

  final AddressModel address;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                address.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(fontSize: 11, color: Colors.green),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(address.fullName),
          const SizedBox(height: 4),
          Text(address.mobile),
          const SizedBox(height: 8),
          Text(address.fullAddress),
        ],
      ),
    );
  }
}
