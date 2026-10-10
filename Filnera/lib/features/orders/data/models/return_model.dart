class ReturnModel {
  const ReturnModel({
    required this.orderId,
    required this.reason,
    required this.status,
    required this.refundAmount,
  });

  final String orderId;
  final String reason;
  final String status;
  final double refundAmount;

  factory ReturnModel.fromJson(Map<String, dynamic> json) {
    return ReturnModel(
      orderId: json['orderId']?.toString() ?? '',
      reason: json['reason']?.toString() ?? 'Product damaged',
      status: json['status']?.toString() ?? 'requested',
      refundAmount: (json['refundAmount'] is num)
          ? (json['refundAmount'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'reason': reason,
    'status': status,
    'refundAmount': refundAmount,
  };
}
