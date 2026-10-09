/// Tracks a section view event for analytics or internal logging.
class TrackSectionViewUseCase {
  const TrackSectionViewUseCase(this._tracker);

  final HomeAnalyticsTracker _tracker;

  Future<void> call({
    required String sectionId,
    required String sectionName,
    String? userId,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return _tracker.trackSectionView(
      sectionId: sectionId,
      sectionName: sectionName,
      userId: userId,
      metadata: metadata,
    );
  }
}

abstract class HomeAnalyticsTracker {
  Future<void> trackSectionView({
    required String sectionId,
    required String sectionName,
    String? userId,
    Map<String, Object?> metadata = const <String, Object?>{},
  });
}
