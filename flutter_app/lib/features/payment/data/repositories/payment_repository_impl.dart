import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/payment_transaction_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_datasource.dart';
import '../datasources/payment_remote_datasource.dart';
import '../models/payment_method_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  final PaymentRemoteDatasource remoteDatasource;
  final PaymentLocalDatasource localDatasource;

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() async {
    final cached = await localDatasource.getCachedMethods();
    if (cached.isNotEmpty) {
      return cached.map((method) => method.toEntity()).toList();
    }

    final remoteMethods = await remoteDatasource.fetchPaymentMethods();
    final models = remoteMethods
        .map((method) => PaymentMethodModel.fromJson(method))
        .toList();

    await localDatasource.cacheMethods(models);
    return models.map((method) => method.toEntity()).toList();
  }

  @override
  Future<PaymentTransactionEntity> initiatePayment({
    required String orderId,
    required double amount,
    required String currency,
    required PaymentMethodEntity method,
  }) async {
    final createdAt = DateTime.now();
    final reference =
        '${method.type.toUpperCase()}-${createdAt.millisecondsSinceEpoch}';

    await Future<void>.delayed(const Duration(milliseconds: 800));

    return PaymentTransactionEntity(
      id: reference,
      orderId: orderId,
      methodId: method.id,
      methodTitle: method.title,
      amount: amount,
      currency: currency,
      status: PaymentStatus.success,
      createdAt: createdAt,
      reference: reference,
      message: 'Payment processed successfully using ${method.title}.',
    );
  }
}
