import '../../data/models/cart_item_model.dart';

class CartEntity {
  const CartEntity({
    required this.items,
    required this.total,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
  });

  final List<CartItemModel> items;
  final double total;
  final double subtotal;
  final double discount;
  final double deliveryFee;

  factory CartEntity.fromModel(Map<String, dynamic> cartJson) {
    final items = (cartJson['items'] as List? ?? const <dynamic>[])
        .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    final subtotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
    final deliveryFee = (cartJson['deliveryFee'] is num)
        ? (cartJson['deliveryFee'] as num).toDouble()
        : 0.0;
    final discount = (cartJson['discount'] is num)
        ? (cartJson['discount'] as num).toDouble()
        : 0.0;

    return CartEntity(
      items: items,
      total: subtotal - discount + deliveryFee,
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
    );
  }
}
