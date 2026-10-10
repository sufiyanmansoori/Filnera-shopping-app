import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository_impl.dart';

class GetProductsUseCase {
  const GetProductsUseCase({required this.repository});

  final ProductRepository repository;

  Future<List<ProductModel>> call({
    String category = 'all',
    int page = 1,
    int pageSize = 20,
  }) async {
    return await repository.fetchProducts(
      category: category,
      page: page,
      pageSize: pageSize,
    );
  }
}
