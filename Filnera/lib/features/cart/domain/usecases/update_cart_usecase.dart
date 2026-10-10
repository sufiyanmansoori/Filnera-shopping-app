import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository_impl.dart';

class UpdateCartUseCase {
  const UpdateCartUseCase({required this._repository});

  final CartRepository _repository;

  Future<CartModel> call(CartModel cart) => _repository.updateCart(cart);
}
