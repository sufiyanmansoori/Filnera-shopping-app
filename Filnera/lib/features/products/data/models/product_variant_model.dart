class ProductVariantModel {
  const ProductVariantModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.priceDelta,
    required this.stock,
    required this.imageUrl,
    this.attributes = const <String, String>{},
  });

  final String id;
  final String name;
  final String sku;
  final double priceDelta;
  final int stock;
  final String imageUrl;
  final Map<String, String> attributes;

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Variant',
      sku: json['sku']?.toString() ?? '',
      priceDelta:
          double.tryParse(
            json['price_delta']?.toString() ??
                json['priceDelta']?.toString() ??
                '0',
          ) ??
          0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      imageUrl:
          json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      attributes:
          (json['attributes'] as Map<String, dynamic>? ??
                  const <String, dynamic>{})
              .map((key, value) => MapEntry(key, value?.toString() ?? '')),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sku': sku,
    'price_delta': priceDelta,
    'stock': stock,
    'image_url': imageUrl,
    'attributes': attributes,
  };
}
