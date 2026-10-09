class RefundModel {
  const RefundModel({
    required this.orderId,
    required this.amount,
    required this.status,
    required this.estimatedDate,
    required this.method,
  });

  final String orderId;
  final double amount;
  final String status;
  final DateTime estimatedDate;
  final String method;

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      orderId:
          json['orderId']?.toString() ?? json['order_id']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0,
      status: json['status']?.toString() ?? 'processing',
      estimatedDate:
          DateTime.tryParse(
            json['estimatedDate']?.toString() ??
                json['estimated_date']?.toString() ??
                '',
          ) ??
          DateTime.now().add(const Duration(days: 5)),
      method: json['method']?.toString() ?? 'Original payment method',
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'amount': amount,
    'status': status,
    'estimatedDate': estimatedDate.toIso8601String(),
    'method': method,
  };
}
