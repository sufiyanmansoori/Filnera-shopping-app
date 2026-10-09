import 'package:equatable/equatable.dart';

/// Represents a reusable home section such as a category row, deal carousel,
/// promo strip, or product rail.
class SectionEntity extends Equatable {
  const SectionEntity({
    required this.id,
    required this.key,
    required this.title,
    required this.type,
    this.subtitle,
    this.description,
    this.itemsCount = 0,
    this.enabled = true,
    this.sortOrder = 0,
    this.viewAllRoute,
    this.metadata = const <String, Object?>{},
  });

  final String id;
  final String key;
  final String title;
  final SectionType type;
  final String? subtitle;
  final String? description;
  final int itemsCount;
  final bool enabled;
  final int sortOrder;
  final String? viewAllRoute;
  final Map<String, Object?> metadata;

  SectionEntity copyWith({
    String? id,
    String? key,
    String? title,
    SectionType? type,
    String? subtitle,
    String? description,
    int? itemsCount,
    bool? enabled,
    int? sortOrder,
    String? viewAllRoute,
    Map<String, Object?>? metadata,
  }) {
    return SectionEntity(
      id: id ?? this.id,
      key: key ?? this.key,
      title: title ?? this.title,
      type: type ?? this.type,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      itemsCount: itemsCount ?? this.itemsCount,
      enabled: enabled ?? this.enabled,
      sortOrder: sortOrder ?? this.sortOrder,
      viewAllRoute: viewAllRoute ?? this.viewAllRoute,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    key,
    title,
    type,
    subtitle,
    description,
    itemsCount,
    enabled,
    sortOrder,
    viewAllRoute,
    metadata,
  ];
}

enum SectionType {
  banner,
  category,
  deal,
  flashSale,
  featured,
  recommendation,
  trending,
  sponsored,
  promotional,
  brand,
  custom,
}
