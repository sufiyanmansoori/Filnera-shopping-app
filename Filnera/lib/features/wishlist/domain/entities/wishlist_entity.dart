import '../../data/models/wishlist_item_model.dart';

class WishlistEntity {
  const WishlistEntity({required this.items, required this.updatedAt});

  final List<WishlistItemModel> items;
  final DateTime updatedAt;

  factory WishlistEntity.fromModel(Map<String, dynamic> json) {
    final items = (json['items'] as List? ?? const <dynamic>[])
        .map(
          (item) => WishlistItemModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

    return WishlistEntity(
      items: items,
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
