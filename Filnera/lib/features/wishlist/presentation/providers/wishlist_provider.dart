import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../lib.dart';

/// Production-oriented state provider for the wishlist feature.
///
/// Responsibilities:
/// - Fetch wishlist
/// - Add products
/// - Remove products
/// - Toggle wishlist state
/// - Refresh wishlist
/// - Track loading state
/// - Track mutation state
/// - Expose errors
/// - Prevent duplicate mutations
/// - Provide optimistic UI helpers
/// - Keep provider state immutable from outside
///
/// The provider intentionally depends on the repository abstraction rather
/// than directly calling HTTP/API services.
///
/// Expected repository contract:
///
/// ```dart
/// abstract class WishlistRepository {
///   Future<WishlistModel> fetchWishlist(String userId);
///
///   Future<void> addToWishlist(
///     String userId,
///     String productId,
///   );
///
///   Future<void> removeFromWishlist(
///     String userId,
///     String productId,
///   );
/// }
/// ```
class WishlistProvider extends ChangeNotifier {
  WishlistProvider({required this._repository});

  final WishlistRepository _repository;

  // ---------------------------------------------------------------------------
  // Private state
  // ---------------------------------------------------------------------------

  bool _isLoading = false;

  bool _isRefreshing = false;

  String? _error;

  WishlistModel _wishlist = WishlistModel(
    items: const <WishlistItemModel>[],
    updatedAt: DateTime.now(),
  );

  String? _activeUserId;

  final Set<String> _addingProductIds = <String>{};

  final Set<String> _removingProductIds = <String>{};

  final Set<String> _mutatingProductIds = <String>{};

  DateTime? _lastSuccessfulFetch;

  int _requestGeneration = 0;

  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Public getters
  // ---------------------------------------------------------------------------

  /// Indicates whether the initial/full wishlist load is running.
  bool get isLoading => _isLoading;

  /// Indicates whether a manual/background refresh is running.
  bool get isRefreshing => _isRefreshing;

  /// Returns the latest error message.
  String? get error => _error;

  /// Returns the current wishlist.
  ///
  /// The returned model should be treated as immutable by consumers.
  WishlistModel get wishlist => _wishlist;

  /// Returns the currently loaded user's ID.
  String? get activeUserId => _activeUserId;

  /// Returns true when the wishlist contains at least one item.
  bool get hasItems => _wishlist.items.isNotEmpty;

  /// Returns true when the wishlist is empty.
  bool get isEmpty => _wishlist.items.isEmpty;

  /// Number of wishlist items.
  int get itemCount => _wishlist.items.length;

  /// Returns the timestamp of the last successful fetch.
  DateTime? get lastSuccessfulFetch => _lastSuccessfulFetch;

  /// True when there is an error.
  bool get hasError => _error != null;

  /// True when no request is currently running.
  bool get isIdle =>
      !_isLoading && !_isRefreshing && _mutatingProductIds.isEmpty;

  /// Returns true if any product mutation is active.
  bool get hasActiveMutation => _mutatingProductIds.isNotEmpty;

  /// IDs currently being added.
  Set<String> get addingProductIds =>
      Set<String>.unmodifiable(_addingProductIds);

  /// IDs currently being removed.
  Set<String> get removingProductIds =>
      Set<String>.unmodifiable(_removingProductIds);

  /// IDs currently undergoing any mutation.
  Set<String> get mutatingProductIds =>
      Set<String>.unmodifiable(_mutatingProductIds);

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _disposed = true;

    _addingProductIds.clear();
    _removingProductIds.clear();
    _mutatingProductIds.clear();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // State notification
  // ---------------------------------------------------------------------------

  void _safeNotify() {
    if (_disposed) {
      return;
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Error handling
  // ---------------------------------------------------------------------------

  void clearError() {
    if (_error == null) {
      return;
    }

    _error = null;
    _safeNotify();
  }

  void _setError(Object error) {
    _error = _normalizeError(error);
  }

  String _normalizeError(Object error) {
    final message = error.toString().trim();

    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length).trim();
    }

    return message;
  }

  // ---------------------------------------------------------------------------
  // Wishlist fetching
  // ---------------------------------------------------------------------------

  /// Fetches the wishlist for [userId].
  ///
  /// This is normally used when:
  /// - user opens wishlist screen
  /// - user signs in
  /// - user switches account
  /// - app starts
  Future<void> fetchWishlist(String userId, {bool force = false}) async {
    final normalizedUserId = userId.trim();

    if (normalizedUserId.isEmpty) {
      _setError(const FormatException('A valid user ID is required.'));

      _safeNotify();
      return;
    }

    if (_isLoading && !force) {
      return;
    }

    final requestId = ++_requestGeneration;

    _activeUserId = normalizedUserId;

    _isLoading = true;
    _error = null;

    _safeNotify();

    try {
      final result = await _repository.fetchWishlist(normalizedUserId);

      if (_disposed) {
        return;
      }

      if (requestId != _requestGeneration) {
        return;
      }

      _wishlist = _sanitizeWishlist(result);

      _lastSuccessfulFetch = DateTime.now();

      _error = null;
    } catch (error) {
      if (_disposed) {
        return;
      }

      if (requestId != _requestGeneration) {
        return;
      }

      _setError(error);
    } finally {
      if (_disposed) {
        // ignore: control_flow_in_finally
        return;
      }

      if (requestId != _requestGeneration) {
        // ignore: control_flow_in_finally
        return;
      }

      _isLoading = false;

      _safeNotify();
    }
  }

  /// Refreshes the currently active user's wishlist.
  Future<void> refresh() async {
    final userId = _activeUserId;

    if (userId == null || userId.trim().isEmpty) {
      return;
    }

    if (_isRefreshing) {
      return;
    }

    final requestId = ++_requestGeneration;

    _isRefreshing = true;
    _error = null;

    _safeNotify();

    try {
      final result = await _repository.fetchWishlist(userId);

      if (_disposed) {
        return;
      }

      if (requestId != _requestGeneration) {
        return;
      }

      _wishlist = _sanitizeWishlist(result);

      _lastSuccessfulFetch = DateTime.now();

      _error = null;
    } catch (error) {
      if (_disposed) {
        return;
      }

      if (requestId != _requestGeneration) {
        return;
      }

      _setError(error);
    } finally {
      if (_disposed) {
        // ignore: control_flow_in_finally
        return;
      }

      if (requestId != _requestGeneration) {
        // ignore: control_flow_in_finally
        return;
      }

      _isRefreshing = false;

      _safeNotify();
    }
  }

  // ---------------------------------------------------------------------------
  // Add product
  // ---------------------------------------------------------------------------

  /// Adds [productId] to the wishlist.
  ///
  /// The repository remains the source of truth.
  Future<bool> addToWishlist(String userId, String productId) async {
    final normalizedUserId = userId.trim();
    final normalizedProductId = productId.trim();

    if (!_validateIdentifiers(normalizedUserId, normalizedProductId)) {
      return false;
    }

    if (_mutatingProductIds.contains(normalizedProductId)) {
      return false;
    }

    if (contains(normalizedProductId)) {
      return true;
    }

    _beginMutation(normalizedProductId, adding: true);

    try {
      await _repository.addToWishlist(normalizedUserId, normalizedProductId);

      if (_disposed) {
        return false;
      }

      _activeUserId = normalizedUserId;

      _removeLocalItem(normalizedProductId);

      // Server response remains authoritative.
      final refreshed = await _repository.fetchWishlist(normalizedUserId);

      if (_disposed) {
        return false;
      }

      _wishlist = _sanitizeWishlist(refreshed);

      _lastSuccessfulFetch = DateTime.now();

      _error = null;

      return true;
    } catch (error) {
      if (!_disposed) {
        _setError(error);
      }

      return false;
    } finally {
      _endMutation(normalizedProductId, adding: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Remove product
  // ---------------------------------------------------------------------------

  /// Removes [productId] from the wishlist.
  Future<bool> removeFromWishlist(String userId, String productId) async {
    final normalizedUserId = userId.trim();
    final normalizedProductId = productId.trim();

    if (!_validateIdentifiers(normalizedUserId, normalizedProductId)) {
      return false;
    }

    if (_mutatingProductIds.contains(normalizedProductId)) {
      return false;
    }

    if (!contains(normalizedProductId)) {
      return true;
    }

    _beginMutation(normalizedProductId, removing: true);

    try {
      await _repository.removeFromWishlist(
        normalizedUserId,
        normalizedProductId,
      );

      if (_disposed) {
        return false;
      }

      _activeUserId = normalizedUserId;

      _removeLocalItem(normalizedProductId);

      final refreshed = await _repository.fetchWishlist(normalizedUserId);

      if (_disposed) {
        return false;
      }

      _wishlist = _sanitizeWishlist(refreshed);

      _lastSuccessfulFetch = DateTime.now();

      _error = null;

      return true;
    } catch (error) {
      if (!_disposed) {
        _setError(error);
      }

      return false;
    } finally {
      _endMutation(normalizedProductId, removing: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Toggle
  // ---------------------------------------------------------------------------

  /// Toggles a product between wishlist and non-wishlist state.
  Future<bool> toggleWishlist({
    required String userId,
    required String productId,
  }) async {
    final normalizedProductId = productId.trim();

    if (normalizedProductId.isEmpty) {
      return false;
    }

    if (contains(normalizedProductId)) {
      return removeFromWishlist(userId, normalizedProductId);
    }

    return addToWishlist(userId, normalizedProductId);
  }

  // ---------------------------------------------------------------------------
  // Membership
  // ---------------------------------------------------------------------------

  /// Returns true if [productId] exists in the wishlist.
  bool contains(String productId) {
    final normalizedId = productId.trim();

    if (normalizedId.isEmpty) {
      return false;
    }

    return _wishlist.items.any(
      (item) => _extractProductId(item) == normalizedId,
    );
  }

  /// Alias for [contains].
  bool isInWishlist(String productId) {
    return contains(productId);
  }

  /// Returns the wishlist item for a product.
  WishlistItemModel? findItem(String productId) {
    final normalizedId = productId.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final item in _wishlist.items) {
      if (_extractProductId(item) == normalizedId) {
        return item;
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Mutation state
  // ---------------------------------------------------------------------------

  bool isAdding(String productId) {
    return _addingProductIds.contains(productId.trim());
  }

  bool isRemoving(String productId) {
    return _removingProductIds.contains(productId.trim());
  }

  bool isMutating(String productId) {
    return _mutatingProductIds.contains(productId.trim());
  }

  void _beginMutation(
    String productId, {
    bool adding = false,
    bool removing = false,
  }) {
    if (adding) {
      _addingProductIds.add(productId);
    }

    if (removing) {
      _removingProductIds.add(productId);
    }

    _mutatingProductIds.add(productId);

    _error = null;

    _safeNotify();
  }

  void _endMutation(
    String productId, {
    bool adding = false,
    bool removing = false,
  }) {
    if (adding) {
      _addingProductIds.remove(productId);
    }

    if (removing) {
      _removingProductIds.remove(productId);
    }

    _mutatingProductIds.remove(productId);

    _safeNotify();
  }

  // ---------------------------------------------------------------------------
  // Local state operations
  // ---------------------------------------------------------------------------

  void _removeLocalItem(String productId) {
    final filtered = _wishlist.items
        .where((item) => _extractProductId(item) != productId)
        .toList(growable: false);

    _wishlist = _copyWishlistWithItems(filtered);

    _safeNotify();
  }

  // ---------------------------------------------------------------------------
  // Local clear/reset
  // ---------------------------------------------------------------------------

  /// Clears the in-memory wishlist.
  ///
  /// This does NOT delete data from the backend.
  void clearLocal() {
    _requestGeneration++;

    _wishlist = WishlistModel(
      items: const <WishlistItemModel>[],
      updatedAt: DateTime.now(),
    );

    _error = null;
    _lastSuccessfulFetch = null;

    _safeNotify();
  }

  /// Clears the current user/session state.
  ///
  /// This does NOT perform a server-side deletion.
  void reset() {
    _requestGeneration++;

    _activeUserId = null;

    _isLoading = false;
    _isRefreshing = false;

    _error = null;

    _wishlist = WishlistModel(
      items: const <WishlistItemModel>[],
      updatedAt: DateTime.now(),
    );

    _addingProductIds.clear();
    _removingProductIds.clear();
    _mutatingProductIds.clear();

    _lastSuccessfulFetch = null;

    _safeNotify();
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  bool _validateIdentifiers(String userId, String productId) {
    if (userId.isEmpty) {
      _setError(const FormatException('A valid user ID is required.'));

      _safeNotify();

      return false;
    }

    if (productId.isEmpty) {
      _setError(const FormatException('A valid product ID is required.'));

      _safeNotify();

      return false;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // Model normalization
  // ---------------------------------------------------------------------------

  WishlistModel _sanitizeWishlist(WishlistModel value) {
    final uniqueItems = <String, WishlistItemModel>{};

    for (final item in value.items) {
      final productId = _extractProductId(item);

      if (productId.isEmpty) {
        continue;
      }

      uniqueItems[productId] = item;
    }

    return _copyWishlistWithItems(uniqueItems.values.toList(growable: false));
  }

  String _extractProductId(WishlistItemModel item) {
    // This assumes WishlistItemModel exposes productId,
    // which is the natural contract for a wishlist item.
    return item.productId.trim();
  }

  WishlistModel _copyWishlistWithItems(List<WishlistItemModel> items) {
    return WishlistModel(
      items: List<WishlistItemModel>.unmodifiable(items),
      updatedAt: DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Convenience state methods
  // ---------------------------------------------------------------------------

  /// Retry loading the active wishlist after an error.
  Future<void> retry() async {
    final userId = _activeUserId;

    if (userId == null || userId.isEmpty) {
      return;
    }

    await fetchWishlist(userId, force: true);
  }

  /// Returns whether the provider has loaded data successfully.
  bool get hasLoadedSuccessfully => _lastSuccessfulFetch != null;

  /// Returns whether this is currently the first load.
  bool get isInitialLoading => _isLoading && _lastSuccessfulFetch == null;

  /// Returns whether data exists while a refresh is happening.
  bool get isRefreshingExistingData => _isRefreshing && hasItems;

  /// Returns the percentage-like progress of wishlist state.
  ///
  /// This is intentionally simple and is useful only for UI.
  double get loadingProgress {
    if (!_isLoading && !_isRefreshing) {
      return 1.0;
    }

    if (_isLoading && !hasItems) {
      return 0.0;
    }

    if (_isRefreshing) {
      return 0.5;
    }

    return 0.5;
  }
}
