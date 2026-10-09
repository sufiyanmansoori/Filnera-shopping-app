import 'order_item_model.dart';

class OrderModel {
  const OrderModel({
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'processing',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      total: (json['total'] is num) ? (json['total'] as num).toDouble() : 0.0,
      items: (json['items'] as List? ?? const <dynamic>[])
          .map(
            (item) => OrderItemModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      shippingAddress:
          json['shippingAddress']?.toString() ??
          json['address']?.toString() ??
          '',
      trackingCode:
          json['trackingCode']?.toString() ??
          json['tracking_code']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'total': total,
    'items': items.map((item) => item.toJson()).toList(),
    'shippingAddress': shippingAddress,
    'trackingCode': trackingCode,
  };
}
