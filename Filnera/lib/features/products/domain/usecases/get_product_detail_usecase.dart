import '../../data/models/product_detail_model.dart';
import '../../data/repositories/product_repository_impl.dart';

class GetProductDetailUseCase {
  const GetProductDetailUseCase({required this.repository});

  final ProductRepository repository;

  Future<ProductDetailModel> call(String id) async {
    return await repository.fetchProductDetails(id);
  }
}
