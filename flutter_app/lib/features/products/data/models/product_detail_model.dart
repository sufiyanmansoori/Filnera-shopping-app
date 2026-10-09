import 'product_model.dart';
import 'product_review_model.dart';
import 'product_specification_model.dart';
import 'product_variant_model.dart';

class ProductDetailModel {
  const ProductDetailModel({
    required this.product,
    required this.variants,
    required this.specifications,
    required this.reviews,
    required this.sellerName,
    required this.deliveryMessage,
    required this.offers,
    required this.images,
  });

  final ProductModel product;
  final List<ProductVariantModel> variants;
  final List<ProductSpecificationModel> specifications;
  final List<ProductReviewModel> reviews;
  final String sellerName;
  final String deliveryMessage;
  final List<String> offers;
  final List<String> images;

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>? ?? json;

    return ProductDetailModel(
      product: ProductModel.fromJson(productJson),
      variants: (json['variants'] as List? ?? const <dynamic>[])
          .map(
            (item) =>
                ProductVariantModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      specifications: (json['specifications'] as List? ?? const <dynamic>[])
          .map(
            (item) => ProductSpecificationModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      reviews: (json['reviews'] as List? ?? const <dynamic>[])
          .map(
            (item) =>
                ProductReviewModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      sellerName:
          json['seller_name']?.toString() ??
          json['sellerName']?.toString() ??
          'Manara Store',
      deliveryMessage:
          json['delivery_message']?.toString() ??
          json['deliveryMessage']?.toString() ??
          'Free delivery available',
      offers: (json['offers'] as List? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      images: (json['images'] as List? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'variants': variants.map((variant) => variant.toJson()).toList(),
    'specifications': specifications.map((spec) => spec.toJson()).toList(),
    'reviews': reviews.map((review) => review.toJson()).toList(),
    'seller_name': sellerName,
    'delivery_message': deliveryMessage,
    'offers': offers,
    'images': images,
  };
}
