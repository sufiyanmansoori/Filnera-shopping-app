import 'cart_item_model.dart';

class CartModel {
  const CartModel({
    required this.items,
    required this.couponCode,
    required this.discount,
    required this.deliveryFee,
  });

  final List<CartItemModel> items;
  final String couponCode;
  final double discount;
  final double deliveryFee;

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get total => subtotal - discount + deliveryFee;

  CartModel copyWith({
    List<CartItemModel>? items,
    String? couponCode,
    double? discount,
    double? deliveryFee,
  }) {
    return CartModel(
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      discount: discount ?? this.discount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
    );
  }

  factory CartModel.empty() => const CartModel(
    items: <CartItemModel>[],
    couponCode: '',
    discount: 0,
    deliveryFee: 0,
  );

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List? ?? const <dynamic>[])
          .map(
            (item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      couponCode: json['couponCode']?.toString() ?? '',
      discount: (json['discount'] is num)
          ? (json['discount'] as num).toDouble()
          : 0,
      deliveryFee: (json['deliveryFee'] is num)
          ? (json['deliveryFee'] as num).toDouble()
          : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'couponCode': couponCode,
    'discount': discount,
    'deliveryFee': deliveryFee,
  };
}
