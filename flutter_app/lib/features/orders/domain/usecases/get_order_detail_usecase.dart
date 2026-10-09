import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository_impl.dart';

class GetOrderDetailUseCase {
  const GetOrderDetailUseCase({required this._repository});

  final OrderRepository _repository;

  Future<OrderModel> call(String orderId) {
    return _repository.fetchOrderById(orderId);
  }
}
