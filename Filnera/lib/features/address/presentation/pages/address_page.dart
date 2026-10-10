import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/address_store.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _house = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();

  @override
  void initState() {
    super.initState();
    AddressStore.load();
  }

  @override
  void dispose() {
    for (final controller in [_name, _phone, _house, _city, _state, _pincode]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await AddressStore.save(
      DeliveryAddress(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        house: _house.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        pincode: _pincode.text.trim(),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Address saved')));
    }
    _formKey.currentState?.reset();
    for (final controller in [_name, _phone, _house, _city, _state, _pincode]) {
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Delivery addresses')),
    body: ValueListenableBuilder<List<DeliveryAddress>>(
      valueListenable: AddressStore.addresses,
      builder: (context, addresses, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...addresses.map(
            (address) => Card(
              child: ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(address.name),
                subtitle: Text('${address.formatted}\n${address.phone}'),
                isThreeLine: true,
                onTap: () async {
                  await AddressStore.choose(address);
                  if (context.mounted) context.pop();
                },
                trailing: IconButton(
                  tooltip: 'Delete address',
                  onPressed: () => AddressStore.remove(address.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Add new address',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_name, 'Full name'),
                _field(_phone, 'Mobile number', keyboard: TextInputType.phone),
                _field(_house, 'House, street and area'),
                Row(
                  children: [
                    Expanded(child: _field(_city, 'City')),
                    const SizedBox(width: 8),
                    Expanded(child: _field(_state, 'State')),
                  ],
                ),
                _field(
                  _pincode,
                  '6-digit pincode',
                  keyboard: TextInputType.number,
                  validator: (value) => RegExp(r'^\d{6}$').hasMatch(value ?? '')
                      ? null
                      : 'Enter a valid pincode',
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save and use this address'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator:
            validator ??
            (value) => (value?.trim().isEmpty ?? true) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
