import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository_impl.dart';

class GetCartUseCase {
  const GetCartUseCase({required this._repository});

  final CartRepository _repository;

  Future<CartModel> call(String userId) => _repository.fetchCart(userId);
}
