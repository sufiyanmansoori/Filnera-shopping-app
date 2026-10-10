import '../../data/models/order_item_model.dart';

class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.total,
    required this.items,
    required this.shippingAddress,
    required this.trackingCode,
  });

  final String id;
  final String userId;
  final String status;
  final DateTime createdAt;
  final double total;
  final List<OrderItemModel> items;
  final String shippingAddress;
  final String trackingCode;

  factory OrderEntity.fromModel(Map<String, dynamic> json) {
    final items = (json['items'] as List? ?? const <dynamic>[])
        .map((item) => OrderItemModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return OrderEntity(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'processing',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      total: (json['total'] is num) ? (json['total'] as num).toDouble() : 0.0,
      items: items,
      shippingAddress: json['shippingAddress']?.toString() ?? '',
      trackingCode: json['trackingCode']?.toString() ?? '',
    );
  }
}
