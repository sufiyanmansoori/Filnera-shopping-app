import '../entities/payment_method_entity.dart';
import '../entities/payment_transaction_entity.dart';

abstract class PaymentRepository {
  Future<List<PaymentMethodEntity>> getPaymentMethods();

  Future<PaymentTransactionEntity> initiatePayment({
    required String orderId,
    required double amount,
    required String currency,
    required PaymentMethodEntity method,
  });
}
