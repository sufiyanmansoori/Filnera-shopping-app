import 'address_model.dart';
import 'delivery_slot_model.dart';

class CheckoutModel {
  const CheckoutModel({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.shippingAddress,
    required this.deliverySlot,
    required this.paymentMethod,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final AddressModel shippingAddress;
  final DeliverySlotModel deliverySlot;
  final String paymentMethod;
  final String notes;
  final DateTime createdAt;

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    return CheckoutModel(
      id: json['id']?.toString() ?? '',
      items: (json['items'] as List? ?? const <dynamic>[])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      deliveryFee:
          double.tryParse(
            json['delivery_fee']?.toString() ??
                json['deliveryFee']?.toString() ??
                '0',
          ) ??
          0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      shippingAddress: AddressModel.fromJson(
        Map<String, dynamic>.from(
          json['shipping_address'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      deliverySlot: DeliverySlotModel.fromJson(
        Map<String, dynamic>.from(
          json['delivery_slot'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      paymentMethod:
          json['payment_method']?.toString() ??
          json['paymentMethod']?.toString() ??
          'cod',
      notes: json['notes']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(
            json['created_at']?.toString() ??
                json['createdAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items,
    'subtotal': subtotal,
    'delivery_fee': deliveryFee,
    'discount': discount,
    'total': total,
    'shipping_address': shippingAddress.toJson(),
    'delivery_slot': deliverySlot.toJson(),
    'payment_method': paymentMethod,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };
}
