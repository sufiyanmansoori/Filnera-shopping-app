import '../entities/payment_method_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentMethodsUseCase {
  const GetPaymentMethodsUseCase(this.repository);

  final PaymentRepository repository;

  Future<List<PaymentMethodEntity>> call() async {
    return repository.getPaymentMethods();
  }
}
