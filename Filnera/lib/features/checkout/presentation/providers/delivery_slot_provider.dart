import 'package:flutter/foundation.dart';

import '../../data/models/delivery_slot_model.dart';
import '../../data/repositories/checkout_repository_impl.dart';

class DeliverySlotProvider extends ChangeNotifier {
  DeliverySlotProvider({CheckoutRepository? repository})
    : _repository = repository ?? CheckoutRepositoryImpl();

  final CheckoutRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<DeliverySlotModel> _slots = const <DeliverySlotModel>[];
  DeliverySlotModel? _selectedSlot;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DeliverySlotModel> get slots => _slots;
  DeliverySlotModel? get selectedSlot => _selectedSlot;

  Future<void> loadSlots() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _slots = await _repository.fetchDeliverySlots();
      _selectedSlot = _slots.firstWhere(
        (slot) => slot.isAvailable,
        orElse: () =>
            _slots.firstOrNull ??
            DeliverySlotModel(
              id: '',
              label: 'No slot available',
              date: DateTime.now(),
              startTime: '',
              endTime: '',
              price: 0,
              isAvailable: false,
            ),
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectSlot(DeliverySlotModel slot) {
    _selectedSlot = slot;
    notifyListeners();
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
