import 'package:flutter/material.dart';

class DeliveryAddressWidget extends StatelessWidget {
  const DeliveryAddressWidget({super.key, required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on_outlined),
        title: const Text('Delivery Address'),
        subtitle: Text(address),
        trailing: const Icon(Icons.edit_outlined),
      ),
    );
  }
}
