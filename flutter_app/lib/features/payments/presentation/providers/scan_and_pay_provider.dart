import 'package:flutter/foundation.dart';

class ScanAndPayState {
  const ScanAndPayState({
    this.status = 'idle',
    this.orderId,
    this.amount = 0.0,
    this.scanResult,
  });

  final String status;
  final String? orderId;
  final double amount;
  final String? scanResult;

  ScanAndPayState copyWith({
    String? status,
    String? orderId,
    double? amount,
    String? scanResult,
  }) {
    return ScanAndPayState(
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      scanResult: scanResult ?? this.scanResult,
    );
  }
}

class ScanAndPayProvider extends ChangeNotifier {
  ScanAndPayProvider();

  ScanAndPayState _state = const ScanAndPayState();
  ScanAndPayState get state => _state;

  void setScanData(String scanned) {
    _state = _state.copyWith(status: 'scanned', scanResult: scanned);
    notifyListeners();
  }

  void setOrder(String orderId, double amount) {
    _state = _state.copyWith(status: 'ready', orderId: orderId, amount: amount);
    notifyListeners();
  }

  void markPaid() {
    _state = _state.copyWith(status: 'paid');
    notifyListeners();
  }

  void markError(String message) {
    _state = _state.copyWith(status: 'error');
    notifyListeners();
  }
}
