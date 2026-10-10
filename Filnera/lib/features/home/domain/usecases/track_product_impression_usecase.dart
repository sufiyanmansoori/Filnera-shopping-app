/// Tracks a product impression event from the home feed.
class TrackProductImpressionUseCase {
  const TrackProductImpressionUseCase(this._tracker);

  final HomeProductTracker _tracker;

  Future<void> call({
    required String productId,
    required String source,
    String? userId,
    String? sectionId,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return _tracker.trackProductImpression(
      productId: productId,
      source: source,
      userId: userId,
      sectionId: sectionId,
      metadata: metadata,
    );
  }
}

abstract class HomeProductTracker {
  Future<void> trackProductImpression({
    required String productId,
    required String source,
    String? userId,
    String? sectionId,
    Map<String, Object?> metadata = const <String, Object?>{},
  });
}
