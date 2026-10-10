import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.read,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool read;

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    title: title,
    message: message,
    type: type,
    createdAt: createdAt,
    read: read ?? this.read,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
    'read': read,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        type: json['type'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        read: json['read'] as bool? ?? false,
      );
}

class NotificationStore {
  NotificationStore._();

  static const _storageKey = 'manara_notifications';
  static final items = ValueNotifier<List<AppNotification>>(
    <AppNotification>[],
  );
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw != null) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        items.value = decoded
            .whereType<Map>()
            .map(
              (entry) =>
                  AppNotification.fromJson(Map<String, dynamic>.from(entry)),
            )
            .toList();
      }
    }
    _initialized = true;
  }

  static int get unreadCount => items.value.where((item) => !item.read).length;

  static Future<void> add({
    required String title,
    required String message,
    String type = 'system',
  }) async {
    final notification = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
      read: false,
    );
    await _save([notification, ...items.value]);
  }

  static Future<void> markRead(String id) async {
    await _save([
      for (final item in items.value)
        item.id == id ? item.copyWith(read: true) : item,
    ]);
  }

  static Future<void> markAllRead() async {
    await _save([for (final item in items.value) item.copyWith(read: true)]);
  }

  static Future<void> remove(String id) async {
    await _save(items.value.where((item) => item.id != id).toList());
  }

  static Future<void> clearAll() async => _save(const []);

  static Future<void> _save(List<AppNotification> value) async {
    items.value = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(value.map((item) => item.toJson()).toList()),
    );
  }
}
