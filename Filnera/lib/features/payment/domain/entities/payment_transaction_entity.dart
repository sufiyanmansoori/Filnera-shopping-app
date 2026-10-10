import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, processing, success, failed, cancelled }

class PaymentTransactionEntity extends Equatable {
  const PaymentTransactionEntity({
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

  bool get isSuccessful => status == PaymentStatus.success;

  @override
  List<Object?> get props => [
    id,
    orderId,
    methodId,
    methodTitle,
    amount,
    currency,
    status,
    createdAt,
    reference,
    message,
  ];
}
