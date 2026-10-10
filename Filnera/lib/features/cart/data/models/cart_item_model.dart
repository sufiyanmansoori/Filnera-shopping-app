class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.variant,
    required this.seller,
  });

  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String variant;
  final String seller;

  double get subtotal => price * quantity;

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? variant,
    String? seller,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      variant: variant ?? this.variant,
      seller: seller ?? this.seller,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      productId:
          json['productId']?.toString() ?? json['product_id']?.toString() ?? '',
      productName:
          json['productName']?.toString() ??
          json['name']?.toString() ??
          'Product',
      productImage:
          json['productImage']?.toString() ?? json['image']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      variant:
          json['variant']?.toString() ??
          json['selectedVariant']?.toString() ??
          'Default',
      seller:
          json['seller']?.toString() ??
          json['sellerName']?.toString() ??
          'Manara Store',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'productImage': productImage,
    'price': price,
    'quantity': quantity,
    'variant': variant,
    'seller': seller,
  };
}
