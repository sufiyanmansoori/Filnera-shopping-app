class BannerEntity {
  const BannerEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.deepLink,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String? deepLink;
  final bool isActive;
}
