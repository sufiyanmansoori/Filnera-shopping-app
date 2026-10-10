import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/address_model.dart';
import '../providers/address_provider.dart';
import '../widgets/address_card.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
        actions: [
          IconButton(
            onPressed: () => _showAddressDialog(context, null),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.addresses.isEmpty
            ? const Center(child: Text('No addresses saved yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(18),
                itemCount: provider.addresses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final address = provider.addresses[index];
                  return AddressCard(
                    address: address,
                    onEdit: () => _showAddressDialog(context, address),
                    onDelete: () =>
                        _confirmDelete(context, provider, address.id),
                    onTap: () => provider.setDefaultAddress(address.id),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showAddressDialog(
    BuildContext context,
    AddressModel? editingAddress,
  ) async {
    final labelController = TextEditingController(
      text: editingAddress?.label ?? 'Home',
    );
    final nameController = TextEditingController(
      text: editingAddress?.fullName ?? '',
    );
    final phoneController = TextEditingController(
      text: editingAddress?.phone ?? '',
    );
    final streetController = TextEditingController(
      text: editingAddress?.street ?? '',
    );
    final cityController = TextEditingController(
      text: editingAddress?.city ?? '',
    );
    final stateController = TextEditingController(
      text: editingAddress?.state ?? '',
    );
    final countryController = TextEditingController(
      text: editingAddress?.country ?? 'India',
    );
    final postalCodeController = TextEditingController(
      text: editingAddress?.postalCode ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(editingAddress == null ? 'Add address' : 'Edit address'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _textField('Label', labelController),
                  const SizedBox(height: 12),
                  _textField('Full name', nameController),
                  const SizedBox(height: 12),
                  _textField('Phone', phoneController),
                  const SizedBox(height: 12),
                  _textField('Street', streetController),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _textField('City', cityController)),
                      const SizedBox(width: 8),
                      Expanded(child: _textField('State', stateController)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _textField('Country', countryController)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _textField('Postal code', postalCodeController),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true || !context.mounted) {
      return;
    }

    final provider = context.read<AddressProvider>();
    final data = AddressModel(
      id:
          editingAddress?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      label: labelController.text.trim(),
      fullName: nameController.text.trim(),
      phone: phoneController.text.trim(),
      street: streetController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      country: countryController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      isDefault: editingAddress?.isDefault ?? false,
      addressType: editingAddress?.addressType ?? 'home',
    );

    if (editingAddress == null) {
      await provider.addAddress(data);
    } else {
      await provider.updateAddress(data);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editingAddress == null ? 'Address added.' : 'Address updated.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AddressProvider provider,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete address?'),
        content: const Text('This address will be removed from your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.removeAddress(id);
    }
  }

  Widget _textField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
