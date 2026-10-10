class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.variant,
    required this.seller,
  });

  final String id;
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final String variant;
  final String seller;

  double get subtotal => price * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productId:
          json['productId']?.toString() ?? json['product_id']?.toString() ?? '',
      productName:
          json['productName']?.toString() ??
          json['name']?.toString() ??
          'Product',
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      variant: json['variant']?.toString() ?? 'Default',
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
    'imageUrl': imageUrl,
    'price': price,
    'quantity': quantity,
    'variant': variant,
    'seller': seller,
  };
}
