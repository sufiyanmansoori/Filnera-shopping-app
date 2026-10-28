import '../../cart/data/models/cart_item_model.dart';

class CheckoutIntentStore {
  CheckoutIntentStore._();

  static CartItemModel? _buyNowItem;

  static CartItemModel? get buyNowItem => _buyNowItem;

  static void startBuyNow(CartItemModel item) {
    _buyNowItem = item;
  }

  static void clear() {
    _buyNowItem = null;
  }
}
