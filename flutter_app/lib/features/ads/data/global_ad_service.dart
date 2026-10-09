import '../../../../data/mock/ad_content.dart';

class GlobalAdService {
  GlobalAdService._();

  static const List<AdContent> liveAds = homeAds;

  static List<AdContent> adsFor(String category) {
    if (category == 'All') return liveAds;
    final categoryAds = liveAds
        .where((ad) => ad.category.toLowerCase() == category.toLowerCase())
        .toList();
    return categoryAds.isNotEmpty ? categoryAds : liveAds;
  }

  static AdContent adForCategory(String category) {
    final visible = adsFor(category);
    return visible.isNotEmpty ? visible.first : liveAds.first;
  }

  static List<AdContent> featuredAdsFor(String category) {
    return adsFor(category);
  }
}
