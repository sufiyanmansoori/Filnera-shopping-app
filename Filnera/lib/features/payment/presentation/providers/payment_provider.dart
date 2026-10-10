import 'package:flutter/foundation.dart';

import '../../data/datasources/payment_local_datasource.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/payment_transaction_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/get_payment_methods_usecase.dart';
import '../../domain/usecases/initiate_payment_usecase.dart';

class PaymentProvider extends ChangeNotifier {
  PaymentProvider({PaymentRepository? repository}) {
    _repository =
        repository ??
        PaymentRepositoryImpl(
          remoteDatasource: const PaymentRemoteDatasource(),
          localDatasource: PaymentLocalDatasource(),
        );
    _getPaymentMethodsUseCase = GetPaymentMethodsUseCase(_repository);
    _initiatePaymentUseCase = InitiatePaymentUseCase(_repository);
  }

  late final PaymentRepository _repository;
  late final GetPaymentMethodsUseCase _getPaymentMethodsUseCase;
  late final InitiatePaymentUseCase _initiatePaymentUseCase;

  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;
  List<PaymentMethodEntity> _methods = const <PaymentMethodEntity>[];
  PaymentMethodEntity? _selectedMethod;
  PaymentTransactionEntity? _lastTransaction;

  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  List<PaymentMethodEntity> get methods => _methods;
  PaymentMethodEntity? get selectedMethod => _selectedMethod;
  PaymentTransactionEntity? get lastTransaction => _lastTransaction;

  Future<void> loadMethods() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final paymentMethods = await _getPaymentMethodsUseCase();
      _methods = paymentMethods;
      _selectedMethod ??= paymentMethods.isNotEmpty
          ? paymentMethods.firstWhere(
              (method) => method.isRecommended,
              orElse: () => paymentMethods.first,
            )
          : null;
    } catch (error) {
      _errorMessage = 'Unable to load payment methods. Please try again.';
      _methods = const <PaymentMethodEntity>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectMethod(PaymentMethodEntity method) {
    if (!method.isEnabled) {
      return;
    }
    _selectedMethod = method;
    _errorMessage = null;
    notifyListeners();
  }

  Future<PaymentTransactionEntity?> confirmPayment({
    required double amount,
    required String orderId,
    required String currency,
  }) async {
    final method = _selectedMethod;
    if (method == null) {
      _errorMessage = 'Please choose a payment method.';
      notifyListeners();
      return null;
    }

    if (amount <= 0) {
      _errorMessage = 'Order amount must be greater than zero.';
      notifyListeners();
      return null;
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final transaction = await _initiatePaymentUseCase(
        orderId: orderId,
        amount: amount,
        currency: currency,
        method: method,
      );
      _lastTransaction = transaction;
      _isProcessing = false;
      notifyListeners();
      return transaction;
    } catch (error) {
      _errorMessage =
          'Payment failed. Please check your payment details and retry.';
      _lastTransaction = null;
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }
}
