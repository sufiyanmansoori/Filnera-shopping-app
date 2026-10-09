import '../../domain/entities/payment_transaction_entity.dart';

class PaymentTransactionModel {
  const PaymentTransactionModel({
    required this.id,
    required this.orderId,
    required this.methodId,
    required this.methodTitle,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.reference,
    this.message,
  });

  factory PaymentTransactionModel.fromEntity(PaymentTransactionEntity entity) {
    return PaymentTransactionModel(
      id: entity.id,
      orderId: entity.orderId,
      methodId: entity.methodId,
      methodTitle: entity.methodTitle,
      amount: entity.amount,
      currency: entity.currency,
      status: entity.status,
      createdAt: entity.createdAt,
      reference: entity.reference,
      message: entity.message,
    );
  }

  final String id;
  final String orderId;
  final String methodId;
  final String methodTitle;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? reference;
  final String? message;

  PaymentTransactionEntity toEntity() {
    return PaymentTransactionEntity(
      id: id,
      orderId: orderId,
      methodId: methodId,
      methodTitle: methodTitle,
      amount: amount,
      currency: currency,
      status: status,
      createdAt: createdAt,
      reference: reference,
      message: message,
    );
  }
}
