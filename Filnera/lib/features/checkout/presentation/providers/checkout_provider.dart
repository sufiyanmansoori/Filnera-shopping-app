import 'package:flutter/foundation.dart';

import '../../data/models/address_model.dart';
import '../../data/models/checkout_model.dart';
import '../../data/models/delivery_slot_model.dart';
import '../../data/repositories/checkout_repository_impl.dart';

class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider({CheckoutRepository? repository})
    : _repository = repository ?? CheckoutRepositoryImpl();

  final CheckoutRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _items = const <Map<String, dynamic>>[];
  AddressModel? _selectedAddress;
  DeliverySlotModel? _selectedSlot;
  String _paymentMethod = 'cod';
  String _notes = '';
  CheckoutModel? _checkout;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get items => _items;
  AddressModel? get selectedAddress => _selectedAddress;
  DeliverySlotModel? get selectedSlot => _selectedSlot;
  String get paymentMethod => _paymentMethod;
  String get notes => _notes;
  CheckoutModel? get checkout => _checkout;

  void setItems(List<Map<String, dynamic>> items) {
    _items = items;
    notifyListeners();
  }

  void setSelectedAddress(AddressModel? address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void setSelectedDeliverySlot(DeliverySlotModel? slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setNotes(String value) {
    _notes = value;
    notifyListeners();
  }

  Future<void> submitOrder() async {
    if (_selectedAddress == null || _selectedSlot == null) {
      _errorMessage = 'Please select a delivery address and slot.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final subtotal = _items.fold<double>(0, (sum, item) {
        final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
        final quantity = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
        return sum + (price * quantity);
      });

      final deliveryFee = _selectedSlot!.price;
      final discount = 0.0;
      final total = subtotal + deliveryFee - discount;

      final orderPayload = <String, dynamic>{
        'items': _items,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'discount': discount,
        'total': total,
        'shipping_address': _selectedAddress!.toJson(),
        'delivery_slot': _selectedSlot!.toJson(),
        'payment_method': _paymentMethod,
        'notes': _notes,
      };

      _checkout = await _repository.placeOrder(orderPayload);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
