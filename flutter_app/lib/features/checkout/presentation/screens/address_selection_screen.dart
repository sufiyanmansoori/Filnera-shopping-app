import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import '../providers/address_provider.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select address')),
      body: Consumer<AddressProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = provider.addresses;
          if (addresses.isEmpty) {
            return const Center(child: Text('No saved addresses yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = addresses[index];
              final isSelected = provider.selectedAddress?.id == address.id;
              return Card(
                child: ListTile(
                  title: Text(address.label),
                  subtitle: Text('${address.fullName}\n${address.fullAddress}'),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : const Icon(Icons.radio_button_unchecked),
                  onTap: () => provider.selectAddress(address),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add new address'),
                content: SizedBox(
                  width: 360,
                  child: TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Enter complete delivery address',
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        final address = AddressModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          label: 'Custom Address',
                          fullName: 'Guest User',
                          mobile: '9999999999',
                          addressLine1: text,
                          addressLine2: '',
                          city: 'Bengaluru',
                          state: 'Karnataka',
                          pinCode: '560001',
                          country: 'India',
                        );
                        context.read<AddressProvider>().saveAddress(address);
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
