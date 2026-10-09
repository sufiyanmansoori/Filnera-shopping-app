import '../entities/payment_method_entity.dart';
import '../entities/payment_transaction_entity.dart';
import '../repositories/payment_repository.dart';

class InitiatePaymentUseCase {
  const InitiatePaymentUseCase(this.repository);

  final PaymentRepository repository;

  Future<PaymentTransactionEntity> call({
    required String orderId,
    required double amount,
    required String currency,
    required PaymentMethodEntity method,
  }) async {
    return repository.initiatePayment(
      orderId: orderId,
      amount: amount,
      currency: currency,
      method: method,
    );
  }
}
