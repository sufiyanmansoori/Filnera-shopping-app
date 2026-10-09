import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.name,
    required this.address,
    this.onTap,
  });

  final String name;
  final String address;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(address),
        trailing: const Icon(Icons.location_on),
        onTap: onTap,
      ),
    );
  }
}
