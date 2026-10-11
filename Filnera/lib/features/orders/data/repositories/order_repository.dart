import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:filnera/core/exceptions/app_exception.dart';
import 'package:filnera/core/exceptions/network_exception.dart';
import 'package:filnera/core/exceptions/validation_exception.dart';
import 'package:filnera/core/network/api_client.dart';
import 'package:filnera/core/network/network_info.dart';

/// Production-grade, globally reusable order repository for the
/// MANARASHOPPINGAPPMAIN Flutter application.
///
/// Responsibilities:
/// - Rich request validation before network traffic starts.
/// - Memory + local cache fallback for list/detail flows.
/// - Clear request/result/error mapping.
/// - Network-aware execution and timeout-aware retries.
/// - Safe pagination support.
/// - Repository lifecycle object kept simple and testable.
class OrderRepository {
  OrderRepository({
    ApiClient? apiClient,
    NetworkInfo? networkInfo,
    OrderCacheStore? cacheStore,
    RetryPolicy? retryPolicy,
  }) : _apiClient = apiClient ?? ApiClient(),
       _networkInfo = networkInfo ?? NetworkInfoImpl(),
       _cacheStore = cacheStore ?? OrderCacheStore(),
       _retryPolicy = retryPolicy ?? const RetryPolicy();

  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final OrderCacheStore _cacheStore;
  final RetryPolicy _retryPolicy;

  bool _isDisposed = false;

  void dispose() {
    _isDisposed = true;
    _cacheStore.clear();
  }

  bool get isDisposed => _isDisposed;

  /// Fetch an order list page.
  Future<RepositoryResult<OrderPage>> getOrders({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? sort,
    bool forceRefresh = false,
    bool allowCacheFallback = true,
  }) async {
    try {
      _validateNotDisposed();
      final validation = _validatePaging(page: page, pageSize: pageSize);
      if (validation != null) {
        return RepositoryResult.failure(validation);
      }

      final cacheKey = _cacheKey(
        endpoint: 'orders',
        page: page,
        pageSize: pageSize,
        status: status,
        sort: sort,
      );

      if (!forceRefresh && allowCacheFallback) {
        final cached = _cacheStore.getOrderPage(cacheKey);
        if (cached != null) {
          return RepositoryResult.success(cached);
        }
      }

      final connected = await _networkInfo.isConnected;
      if (!connected) {
        final cached = _cacheStore.getOrderPage(cacheKey);
        if (cached != null) {
          return RepositoryResult.success(cached, source: ResultSource.cache);
        }
        return RepositoryResult.failure(
          NetworkException(
            'Network is unavailable. Please check your connection.',
          ),
        );
      }

      final pageResult = await _executeWithRetry(
        operation: () async {
          final response = await _apiClient.get(
            '/orders',
            queryParameters: {
              'page': page,
              'page_size': pageSize,
              if (status != null && status.trim().isNotEmpty)
                'status': status.trim(),
              if (sort != null && sort.trim().isNotEmpty) 'sort': sort.trim(),
            },
          );
          return _parseOrderPage(response.data);
        },
        retryPolicy: _retryPolicy,
      );

      if (pageResult.isSuccess) {
        _cacheStore.putOrderPage(cacheKey, pageResult.value!);
        return pageResult;
      }

      return pageResult;
    } on ValidationException catch (e) {
      return RepositoryResult.failure(e);
    } on NetworkException catch (e) {
      return RepositoryResult.failure(e);
    } on DioException catch (e) {
      return RepositoryResult.failure(_mapDioException(e));
    } on TimeoutException catch (e) {
      return RepositoryResult.failure(
        NetworkException(
          'Request timed out while loading orders: ${e.message}',
        ),
      );
    } catch (e) {
      return RepositoryResult.failure(
        AppException('Unable to load orders. ${e.toString()}'),
      );
    }
  }

  /// Get one order detail by id.
  Future<RepositoryResult<Order>> getOrderDetails({
    required String orderId,
    bool forceRefresh = false,
    bool allowCacheFallback = true,
  }) async {
    try {
      _validateNotDisposed();
      final validation = _validateRequired(
        fieldName: 'orderId',
        value: orderId,
      );
      if (validation != null) {
        return RepositoryResult.failure(validation);
      }

      final cacheKey = 'order-detail-$orderId';

      if (!forceRefresh && allowCacheFallback) {
        final cached = _cacheStore.getOrderDetail(cacheKey);
        if (cached != null) {
          return RepositoryResult.success(cached, source: ResultSource.cache);
        }
      }

      final connected = await _networkInfo.isConnected;
      if (!connected) {
        final cached = _cacheStore.getOrderDetail(cacheKey);
        if (cached != null) {
          return RepositoryResult.success(cached, source: ResultSource.cache);
        }
        return RepositoryResult.failure(
          NetworkException(
            'Network is unavailable. Please check your connection.',
          ),
        );
      }

      final detailResult = await _executeWithRetry(
        operation: () async {
          final response = await _apiClient.get('/orders/$orderId');
          return _parseOrder(response.data);
        },
        retryPolicy: _retryPolicy,
      );

      if (detailResult.isSuccess) {
        _cacheStore.putOrderDetail(cacheKey, detailResult.value!);
      }

      return detailResult;
    } on ValidationException catch (e) {
      return RepositoryResult.failure(e);
    } on NetworkException catch (e) {
      return RepositoryResult.failure(e);
    } on DioException catch (e) {
      return RepositoryResult.failure(_mapDioException(e));
    } catch (e) {
      return RepositoryResult.failure(
        AppException('Unable to load order details. ${e.toString()}'),
      );
    }
  }

  /// Cancel an existing order.
  Future<RepositoryResult<Order>> cancelOrder({
    required String orderId,
    String? reason,
    bool forceRefresh = false,
  }) async {
    try {
      _validateNotDisposed();
      final validation = _validateRequired(
        fieldName: 'orderId',
        value: orderId,
      );
      if (validation != null) {
        return RepositoryResult.failure(validation);
      }

      final connected = await _networkInfo.isConnected;
      if (!connected) {
        return RepositoryResult.failure(
          NetworkException(
            'Network is unavailable. Cancellation cannot be processed offline.',
          ),
        );
      }

      final result = await _executeWithRetry(
        operation: () async {
          final response = await _apiClient.post(
            '/orders/$orderId/cancel',
            data: {
              'reason': reason ?? 'Customer requested cancellation',
              'cancelled_at': DateTime.now().toUtc().toIso8601String(),
            },
          );
          final order = _parseOrder(response.data);
          _cacheStore.invalidateOrder(order.id);
          return order;
        },
        retryPolicy: _retryPolicy,
      );

      if (result.isSuccess) {
        final order = result.value!;
        _cacheStore.putOrderDetail('order-detail-${order.id}', order);
      }

      return result;
    } on ValidationException catch (e) {
      return RepositoryResult.failure(e);
    } on NetworkException catch (e) {
      return RepositoryResult.failure(e);
    } on DioException catch (e) {
      return RepositoryResult.failure(_mapDioException(e));
    } catch (e) {
      return RepositoryResult.failure(
        AppException('Unable to cancel order. ${e.toString()}'),
      );
    }
  }

  /// Reorder an order from an existing order id.
  Future<RepositoryResult<OrderReorderResult>> reorder({
    required String orderId,
    bool includePreviousCart = false,
  }) async {
    try {
      _validateNotDisposed();
      final validation = _validateRequired(
        fieldName: 'orderId',
        value: orderId,
      );
      if (validation != null) {
        return RepositoryResult.failure(validation);
      }

      final connected = await _networkInfo.isConnected;
      if (!connected) {
        return RepositoryResult.failure(
          NetworkException(
            'Network is unavailable. Reorder cannot be processed offline.',
          ),
        );
      }

      final result = await _executeWithRetry(
        operation: () async {
          final response = await _apiClient.post(
            '/orders/$orderId/reorder',
            data: {
              'include_previous_cart': includePreviousCart,
              'requested_at': DateTime.now().toUtc().toIso8601String(),
            },
          );
          return _parseReorderResult(response.data);
        },
        retryPolicy: _retryPolicy,
      );

      if (result.isSuccess) {
        _cacheStore.invalidatePrefix('orders');
      }

      return result;
    } on ValidationException catch (e) {
      return RepositoryResult.failure(e);
    } on NetworkException catch (e) {
      return RepositoryResult.failure(e);
    } on DioException catch (e) {
      return RepositoryResult.failure(_mapDioException(e));
    } catch (e) {
      return RepositoryResult.failure(
        AppException('Unable to reorder order. ${e.toString()}'),
      );
    }
  }

  /// Track order status and shipment progress.
  Future<RepositoryResult<OrderTracking>> trackOrder({
    required String orderId,
    bool forceRefresh = false,
    bool allowCacheFallback = true,
  }) async {
    try {
      _validateNotDisposed();
      final validation = _validateRequired(
        fieldName: 'orderId',
        value: orderId,
      );
      if (validation != null) {
        return RepositoryResult.failure(validation);
      }

      final cacheKey = 'order-track-$orderId';

      if (!forceRefresh && allowCacheFallback) {
        final cached = _cacheStore.getTracking(cacheKey);
        if (cached != null) {
          return RepositoryResult.success(cached, source: ResultSource.cache);
        }
      }

      final connected = await _networkInfo.isConnected;
      if (!connected) {
        final cached = _cacheStore.getTracking(cacheKey);
        if (cached != null) {
          return RepositoryResult.success(cached, source: ResultSource.cache);
        }
        return RepositoryResult.failure(
          NetworkException(
            'Network is unavailable. Tracking data cannot be loaded offline.',
          ),
        );
      }

      final trackingResult = await _executeWithRetry(
        operation: () async {
          final response = await _apiClient.get('/orders/$orderId/track');
          return _parseTracking(response.data);
        },
        retryPolicy: _retryPolicy,
      );

      if (trackingResult.isSuccess) {
        _cacheStore.putTracking(cacheKey, trackingResult.value!);
      }

      return trackingResult;
    } on ValidationException catch (e) {
      return RepositoryResult.failure(e);
    } on NetworkException catch (e) {
      return RepositoryResult.failure(e);
    } on DioException catch (e) {
      return RepositoryResult.failure(_mapDioException(e));
    } catch (e) {
      return RepositoryResult.failure(
        AppException('Unable to track order. ${e.toString()}'),
      );
    }
  }

  /// Force refresh the order list. This clears caches if needed and loads remote.
  Future<RepositoryResult<OrderPage>> refreshOrders({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? sort,
    bool allowCacheFallback = true,
  }) async {
    return getOrders(
      page: page,
      pageSize: pageSize,
      status: status,
      sort: sort,
      forceRefresh: true,
      allowCacheFallback: allowCacheFallback,
    );
  }

  /// Invalidate all cached order resources.
  Future<void> invalidateOrdersCache({String? prefix}) async {
    _validateNotDisposed();
    if (prefix != null && prefix.trim().isNotEmpty) {
      _cacheStore.invalidatePrefix(prefix);
      return;
    }
    _cacheStore.clear();
  }

  /// Invalidate a single detail cache entry.
  Future<void> invalidateOrderDetailCache(String orderId) async {
    _validateNotDisposed();
    _cacheStore.invalidateOrder(orderId);
  }

  AppException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException('Request timed out while contacting server.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException('Network connection failed.');
    }

    if (error.type == DioExceptionType.badResponse) {
      final status = error.response?.statusCode;
      final map = error.response?.data;
      final message = _extractServerMessage(map);

      if (status == 400) {
        return ValidationException(
          message.isNotEmpty ? message : 'Bad request.',
        );
      }
      if (status == 401) {
        return AppException('Authentication expired. Please sign in again.');
      }
      if (status == 403) {
        return AppException(
          'Forbidden. You do not have permission to perform this action.',
        );
      }
      if (status == 404) {
        return AppException('Order resource was not found.');
      }
      if (status == 409) {
        return AppException('Conflict while updating this order.');
      }
      if (status == 422) {
        return ValidationException(
          message.isNotEmpty ? message : 'Validation failed.',
        );
      }
      if (status == 500 || status == 502 || status == 503 || status == 504) {
        return NetworkException(
          'Server error while processing the order request.',
        );
      }
    }

    final message = _extractServerMessage(error.response?.data);
    return NetworkException(
      message.isNotEmpty ? message : 'Network request failed.',
    );
  }

  String _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'] ?? data['detail'] ?? '')
          as String;
    }
    if (data is Map) {
      return (data['message'] ?? data['error'] ?? data['detail'] ?? '')
          as String;
    }
    if (data is String) return data;
    return '';
  }

  AppException? _validatePaging({required int page, required int pageSize}) {
    if (page < 1) {
      return ValidationException('Page must be at least 1.');
    }
    if (pageSize < 1 || pageSize > 100) {
      return ValidationException('Page size must be between 1 and 100.');
    }
    return null;
  }

  ValidationException? _validateRequired({
    required String fieldName,
    required String value,
  }) {
    if (value.trim().isEmpty) {
      return ValidationException('$fieldName is required.');
    }
    return null;
  }

  void _validateNotDisposed() {
    if (_isDisposed) {
      throw StateError('OrderRepository has been disposed and cannot be used.');
    }
  }

  String _cacheKey({
    required String endpoint,
    int? page,
    int? pageSize,
    String? status,
    String? sort,
  }) {
    final parts = <String>[
      endpoint,
      if (page != null) 'page=$page',
      if (pageSize != null) 'pageSize=$pageSize',
      if (status != null && status.trim().isNotEmpty) 'status=${status.trim()}',
      if (sort != null && sort.trim().isNotEmpty) 'sort=${sort.trim()}',
    ];
    return parts.join('|');
  }

  Future<RepositoryResult<T>> _executeWithRetry<T>({
    required Future<T> Function() operation,
    required RetryPolicy retryPolicy,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        final value = await operation();
        return RepositoryResult.success(value);
      } on DioException catch (e) {
        final shouldRetry = retryPolicy.allowRetry(attempt, e);
        if (!shouldRetry) {
          return RepositoryResult.failure(_mapDioException(e));
        }
        attempt++;
        if (attempt >= retryPolicy.maxAttempts) {
          return RepositoryResult.failure(_mapDioException(e));
        }
        await Future.delayed(retryPolicy.delayForAttempt(attempt));
      } on TimeoutException catch (e) {
        final shouldRetry = retryPolicy.allowRetry(attempt, e);
        if (!shouldRetry) {
          return RepositoryResult.failure(NetworkException(e.toString()));
        }
        attempt++;
        if (attempt >= retryPolicy.maxAttempts) {
          return RepositoryResult.failure(NetworkException(e.toString()));
        }
        await Future.delayed(retryPolicy.delayForAttempt(attempt));
      } catch (e) {
        return RepositoryResult.failure(AppException(e.toString()));
      }
    }
  }

  OrderPage _parseOrderPage(dynamic data) {
    final page = OrderPage();
    if (data is Map<String, dynamic>) {
      final items = data['items'] is List
          ? data['items'] as List
          : const <dynamic>[];
      final list = items.map<Order>(_parseOrderFromMap).toList();
      page.items = list;
      page.page = (data['page'] ?? 1) as int;
      page.pageSize = (data['page_size'] ?? list.length) as int;
      page.totalItems = (data['total_items'] ?? list.length) as int;
      page.totalPages = (data['total_pages'] ?? 1) as int;
      page.hasNextPage = (data['has_next_page'] ?? false) as bool;
      page.hasPreviousPage = (data['has_previous_page'] ?? false) as bool;
      return page;
    }

    if (data is List) {
      page.items = data.map<Order>(_parseOrderFromMap).toList();
      page.page = 1;
      page.pageSize = data.length;
      page.totalItems = data.length;
      page.totalPages = 1;
      return page;
    }

    return page;
  }

  Order _parseOrder(dynamic data) {
    if (data is Map<String, dynamic>) {
      return _parseOrderFromMap(data);
    }
    if (data is Map) {
      return _parseOrderFromMap(Map<String, dynamic>.from(data));
    }
    throw AppException('Unsupported order detail payload format.');
  }

  Order _parseOrderFromMap(dynamic map) {
    if (map is! Map<String, dynamic>) {
      if (map is Map) {
        map = Map<String, dynamic>.from(map);
      } else {
        throw AppException('Invalid order payload.');
      }
    }

    return Order(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      status: map['status']?.toString() ?? 'unknown',
      total: (map['total'] is num)
          ? (map['total'] as num).toDouble()
          : double.tryParse(map['total']?.toString() ?? '0') ?? 0,
      currency: map['currency']?.toString() ?? 'USD',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      items: (map['items'] is List)
          ? (map['items'] as List)
                .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const <OrderItem>[],
      trackingNumber: map['tracking_number']?.toString(),
      address: map['address'] != null && map['address'] is Map
          ? OrderAddress.fromJson(Map<String, dynamic>.from(map['address']))
          : null,
      paymentMethod: map['payment_method']?.toString() ?? '',
      orderNumber: map['order_number']?.toString() ?? '',
      subtotal: (map['subtotal'] is num)
          ? (map['subtotal'] as num).toDouble()
          : double.tryParse(map['subtotal']?.toString() ?? '0') ?? 0,
      shippingFee: (map['shipping_fee'] is num)
          ? (map['shipping_fee'] as num).toDouble()
          : double.tryParse(map['shipping_fee']?.toString() ?? '0') ?? 0,
      tax: (map['tax'] is num)
          ? (map['tax'] as num).toDouble()
          : double.tryParse(map['tax']?.toString() ?? '0') ?? 0,
      discount: (map['discount'] is num)
          ? (map['discount'] as num).toDouble()
          : double.tryParse(map['discount']?.toString() ?? '0') ?? 0,
      notes: map['notes']?.toString(),
    );
  }

  OrderReorderResult _parseReorderResult(dynamic data) {
    if (data is Map<String, dynamic>) {
      final orderId = data['order_id']?.toString() ?? '';
      final cartId = data['cart_id']?.toString() ?? '';
      final newOrder = data['order'] is Map
          ? _parseOrderFromMap(Map<String, dynamic>.from(data['order']))
          : null;
      return OrderReorderResult(
        cartId: cartId,
        orderId: orderId,
        newOrder: newOrder,
        message:
            data['message']?.toString() ?? 'Order placed from previous order.',
      );
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      return _parseReorderResult(map);
    }
    return OrderReorderResult(
      cartId: '',
      orderId: '',
      newOrder: null,
      message: 'Reorder created successfully.',
    );
  }

  OrderTracking _parseTracking(dynamic data) {
    if (data is Map<String, dynamic>) {
      final events = data['events'] is List
          ? (data['events'] as List)
                .map(
                  (e) =>
                      OrderTrackingEvent.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const <OrderTrackingEvent>[];

      return OrderTracking(
        orderId: data['order_id']?.toString() ?? '',
        status: data['status']?.toString() ?? 'unknown',
        courierName: data['courier_name']?.toString(),
        trackingNumber: data['tracking_number']?.toString(),
        estimatedDeliveryAt: data['estimated_delivery_at'] != null
            ? DateTime.tryParse(data['estimated_delivery_at'].toString())
            : null,
        events: events,
      );
    }
    if (data is Map) {
      return _parseTracking(Map<String, dynamic>.from(data));
    }
    return OrderTracking(orderId: '', status: 'unknown');
  }
}

/// Generic build-safe repository result wrapper.
class RepositoryResult<T> {
  RepositoryResult.success(this.value, {this.source = ResultSource.network})
    : isSuccess = true,
      error = null;

  RepositoryResult.failure(this.error, {this.source = ResultSource.network})
    : isSuccess = false,
      value = null;

  final T? value;
  final AppException? error;
  final bool isSuccess;
  final ResultSource source;

  bool get hasValue => value != null;

  @override
  String toString() {
    if (isSuccess) return 'RepositoryResult.success($value)';
    return 'RepositoryResult.failure($error)';
  }
}

enum ResultSource { network, cache, memory }

/// A simple in-memory cache abstraction and fallback store.
class OrderCacheStore {
  final Map<String, OrderPage> _pages = <String, OrderPage>{};
  final Map<String, Order> _details = <String, Order>{};
  final Map<String, OrderTracking> _tracking = <String, OrderTracking>{};

  OrderPage? getOrderPage(String key) => _pages[key];
  Order? getOrderDetail(String key) => _details[key];
  OrderTracking? getTracking(String key) => _tracking[key];

  void putOrderPage(String key, OrderPage page) => _pages[key] = page;
  void putOrderDetail(String key, Order detail) => _details[key] = detail;
  void putTracking(String key, OrderTracking tracking) =>
      _tracking[key] = tracking;

  void invalidateOrder(String orderId) {
    final keys = _details.keys.where((key) => key.contains(orderId)).toList();
    for (final key in keys) {
      _details.remove(key);
    }
  }

  void invalidatePrefix(String prefix) {
    final keys = _pages.keys.where((key) => key.startsWith(prefix)).toList();
    for (final key in keys) {
      _pages.remove(key);
    }
    final details = _details.keys
        .where((key) => key.startsWith(prefix))
        .toList();
    for (final key in details) {
      _details.remove(key);
    }
  }

  void clear() {
    _pages.clear();
    _details.clear();
    _tracking.clear();
  }
}

/// Timeout and retry strategy.
class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 300),
    this.maxDelay = const Duration(seconds: 2),
    this.retryOnStatuses = const {408, 429, 500, 502, 503, 504},
  });

  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final Set<int> retryOnStatuses;

  bool allowRetry(int attempt, Object error) {
    if (attempt >= maxAttempts - 1) return false;

    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status != null && retryOnStatuses.contains(status)) return true;
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return true;
      }
      if (error.type == DioExceptionType.badResponse &&
          error.response?.statusCode == 502) {
        return true;
      }
    }

    if (error is TimeoutException) return true;

    return false;
  }

  Duration delayForAttempt(int attempt) {
    final factor = math.min(
      math.pow(2, attempt).toInt(),
      maxDelay.inMilliseconds,
    );
    final ms = initialDelay.inMilliseconds * factor;
    return Duration(milliseconds: ms);
  }
}

/// Order page model for pagination.
class OrderPage {
  OrderPage({
    this.items = const <Order>[],
    this.page = 1,
    this.pageSize = 20,
    this.totalItems = 0,
    this.totalPages = 1,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  List<Order> items;
  int page;
  int pageSize;
  int totalItems;
  int totalPages;
  bool hasNextPage;
  bool hasPreviousPage;

  bool get isEmpty => items.isEmpty;
}

/// Main domain model for one order.
class Order {
  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.total,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.items = const <OrderItem>[],
    this.trackingNumber,
    this.address,
    this.paymentMethod = '',
    this.orderNumber = '',
    this.subtotal = 0,
    this.shippingFee = 0,
    this.tax = 0,
    this.discount = 0,
    this.notes,
  });

  final String id;
  final String userId;
  final String status;
  final double total;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
  final String? trackingNumber;
  final OrderAddress? address;
  final String paymentMethod;
  final String orderNumber;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double discount;
  final String? notes;

  bool get isCanceled =>
      status.toLowerCase() == 'canceled' || status.toLowerCase() == 'cancelled';
  bool get isDelivered => status.toLowerCase() == 'delivered';

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'status': status,
    'total': total,
    'currency': currency,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'payment_method': paymentMethod,
    'order_number': orderNumber,
    'subtotal': subtotal,
    'shipping_fee': shippingFee,
    'tax': tax,
    'discount': discount,
    'notes': notes,
  };
}

class OrderItem {
  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.currency,
    this.variant,
  });

  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String currency;
  final String? variant;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id']?.toString() ?? json['id']?.toString() ?? '',
      productName:
          json['product_name']?.toString() ?? json['name']?.toString() ?? '',
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      currency: json['currency']?.toString() ?? 'USD',
      variant: json['variant']?.toString(),
    );
  }
}

class OrderAddress {
  OrderAddress({
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.phone,
  });

  final String firstName;
  final String lastName;
  final String addressLine1;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String phone;

  factory OrderAddress.fromJson(Map<String, dynamic> json) => OrderAddress(
    firstName: json['first_name']?.toString() ?? '',
    lastName: json['last_name']?.toString() ?? '',
    addressLine1:
        json['address_line_1']?.toString() ?? json['street']?.toString() ?? '',
    city: json['city']?.toString() ?? '',
    state: json['state']?.toString() ?? '',
    country: json['country']?.toString() ?? '',
    postalCode:
        json['postal_code']?.toString() ?? json['zip']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
  );
}

class OrderTracking {
  OrderTracking({
    required this.orderId,
    required this.status,
    this.courierName,
    this.trackingNumber,
    this.estimatedDeliveryAt,
    this.events = const <OrderTrackingEvent>[],
  });

  final String orderId;
  final String status;
  final String? courierName;
  final String? trackingNumber;
  final DateTime? estimatedDeliveryAt;
  final List<OrderTrackingEvent> events;
}

class OrderTrackingEvent {
  OrderTrackingEvent({
    required this.status,
    required this.message,
    required this.createdAt,
  });

  final String status;
  final String message;
  final DateTime createdAt;

  factory OrderTrackingEvent.fromJson(Map<String, dynamic> json) {
    return OrderTrackingEvent(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class OrderReorderResult {
  OrderReorderResult({
    required this.cartId,
    required this.orderId,
    required this.newOrder,
    required this.message,
  });

  final String cartId;
  final String orderId;
  final Order? newOrder;
  final String message;
}
