import 'home_data_model.dart';
import 'home_metadata_model.dart';

const Object _unset = Object();

/// API envelope for the home endpoint. Product content is delegated to
/// [HomeDataModel], while transport metadata stays at the response boundary.
class HomeResponseModel {
  HomeResponseModel({
    required this.data,
    this.success = true,
    this.message,
    this.statusCode,
    this.requestId,
    this.timestamp,
    List<String> errors = const <String>[],
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) : errors = List<String>.unmodifiable(errors),
       metadata = Map<String, dynamic>.unmodifiable(metadata);

  final HomeDataModel data;
  final bool success;
  final String? message;
  final int? statusCode;
  final String? requestId;
  final DateTime? timestamp;
  final List<String> errors;
  final Map<String, dynamic> metadata;

  HomeMetadataModel get homeMetadata => HomeMetadataModel.fromJson(metadata);

  bool get isSuccessful =>
      success &&
      (statusCode == null || (statusCode! >= 200 && statusCode! < 300));

  bool get hasData => data.toEntity().hasContent;

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    final statusCode = _integer(
      json['status_code'] ?? json['statusCode'] ?? json['code'],
    );
    final errors = _errorMessages(json['errors'] ?? json['error']);
    final success = _boolean(
      json['success'] ?? json['ok'],
      fallback: errors.isEmpty && (statusCode == null || statusCode < 400),
    );

    return HomeResponseModel(
      data: HomeDataModel.fromJson(json),
      success: success,
      message: _text(json['message'] ?? json['detail']),
      statusCode: statusCode,
      requestId: _text(
        json['request_id'] ?? json['requestId'] ?? json['trace_id'],
      ),
      timestamp: _dateTime(
        json['timestamp'] ??
            json['generated_at'] ??
            json['generatedAt'] ??
            json['updated_at'],
      ),
      errors: errors,
      metadata: _stringKeyedMap(json['metadata'] ?? json['meta']),
    );
  }

  factory HomeResponseModel.fromData(
    HomeDataModel data, {
    String? message,
    int? statusCode,
    String? requestId,
    DateTime? timestamp,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) => HomeResponseModel(
    data: data,
    message: message,
    statusCode: statusCode,
    requestId: requestId,
    timestamp: timestamp,
    metadata: metadata,
  );

  HomeResponseModel copyWith({
    HomeDataModel? data,
    bool? success,
    Object? message = _unset,
    Object? statusCode = _unset,
    Object? requestId = _unset,
    Object? timestamp = _unset,
    List<String>? errors,
    Map<String, dynamic>? metadata,
  }) {
    return HomeResponseModel(
      data: data ?? this.data,
      success: success ?? this.success,
      message: identical(message, _unset) ? this.message : message as String?,
      statusCode: identical(statusCode, _unset)
          ? this.statusCode
          : statusCode as int?,
      requestId: identical(requestId, _unset)
          ? this.requestId
          : requestId as String?,
      timestamp: identical(timestamp, _unset)
          ? this.timestamp
          : timestamp as DateTime?,
      errors: errors ?? this.errors,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'success': success,
    'data': data.toJson(),
    if (message != null) 'message': message,
    if (statusCode != null) 'status_code': statusCode,
    if (requestId != null) 'request_id': requestId,
    if (timestamp != null) 'timestamp': timestamp!.toUtc().toIso8601String(),
    if (errors.isNotEmpty) 'errors': errors,
    if (metadata.isNotEmpty) 'meta': metadata,
  };

  static Map<String, dynamic> _stringKeyedMap(dynamic value) {
    if (value is! Map) return const <String, dynamic>{};
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  static String? _text(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _integer(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static bool _boolean(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case '1':
        case 'yes':
        case 'ok':
        case 'success':
          return true;
        case 'false':
        case '0':
        case 'no':
        case 'error':
        case 'failed':
          return false;
      }
    }
    return fallback;
  }

  static DateTime? _dateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static List<String> _errorMessages(dynamic value) {
    if (value == null) return const <String>[];
    if (value is String) {
      final message = value.trim();
      return message.isEmpty ? const <String>[] : <String>[message];
    }
    if (value is Iterable) {
      return value.expand(_errorMessages).toList(growable: false);
    }
    if (value is Map) {
      return value.entries
          .expand((entry) {
            final key = entry.key.toString();
            final messages = _errorMessages(entry.value);
            if (key == 'message' || key == 'detail') return messages;
            return messages.map((message) => '$key: $message');
          })
          .toList(growable: false);
    }
    return const <String>[];
  }
}
