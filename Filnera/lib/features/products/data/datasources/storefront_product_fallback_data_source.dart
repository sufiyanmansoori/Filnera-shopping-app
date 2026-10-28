import '../../../../data/mock/mock_products.dart' as storefront;
import '../models/product_model.dart' as api;

class StorefrontProductFallbackDataSource {
  api.ProductModel? findById(String id) {
    for (final product in storefront.mockProducts) {
      if (product.id == id) {
        return api.ProductModel(
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          compareAtPrice: product.originalPrice,
          category: product.category,
          brand: 'Filnera',
          imageUrl: product.imageUrl,
          images: product.gallery,
          rating: product.rating,
          reviewCount: product.reviewCount,
          stock: product.stock,
          isFeatured: product.isFeatured,
          sellerName: 'Manara Store',
          tags: product.features,
          shortDescription: product.description,
          specifications: <String, dynamic>{
            'Highlights': product.features.join(', '),
          },
          offers: const <String>[
            'Free delivery available',
            'Easy returns',
          ],
        );
      }
    }
    return null;
  }
}
