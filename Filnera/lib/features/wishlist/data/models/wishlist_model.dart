import 'wishlist_item_model.dart';

class WishlistModel {
  const WishlistModel({required this.items, required this.updatedAt});

  final List<WishlistItemModel> items;
  final DateTime updatedAt;

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      items: (json['items'] as List? ?? const <dynamic>[])
          .map(
            (item) =>
                WishlistItemModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
