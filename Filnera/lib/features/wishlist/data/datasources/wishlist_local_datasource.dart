import 'package:shared_preferences/shared_preferences.dart';

import '../models/wishlist_model.dart';

class WishlistLocalDataSource {
  static const String _wishlistKey = 'wishlist_cache_v1';

  Future<WishlistModel?> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_wishlistKey);
    if (raw == null || raw.isEmpty) return null;
    return WishlistModel.fromJson(<String, dynamic>{
      'items': const <dynamic>[],
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveWishlist(WishlistModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wishlistKey, model.toJson().toString());
  }
}
