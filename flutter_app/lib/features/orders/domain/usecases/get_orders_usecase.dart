import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository_impl.dart';

class GetOrdersUseCase {
  const GetOrdersUseCase({required this._repository});

  final OrderRepository _repository;

  Future<List<OrderModel>> call({String status = 'all'}) {
    return _repository.fetchOrders(status: status);
  }
}
