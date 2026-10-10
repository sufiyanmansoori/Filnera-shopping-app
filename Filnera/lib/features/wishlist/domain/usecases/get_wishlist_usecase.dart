import '../../data/models/wishlist_model.dart';
import '../../data/repositories/wishlist_repository_impl.dart';

class GetWishlistUseCase {
  const GetWishlistUseCase({required this._repository});

  final WishlistRepository _repository;

  Future<WishlistModel> call(String userId) {
    return _repository.fetchWishlist(userId);
  }
}
