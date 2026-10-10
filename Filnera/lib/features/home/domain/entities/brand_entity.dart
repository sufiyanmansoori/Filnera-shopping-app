import 'package:equatable/equatable.dart';

/// Brand spotlight block used for fashion or marketplace sponsorships.
class BrandEntity extends Equatable {
  const BrandEntity({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.tagline,
    this.story,
    this.websiteUrl,
    this.isCurated = false,
    this.priority = 0,
  });

  final String id;
  final String name;
  final String logoUrl;
  final String? tagline;
  final String? story;
  final String? websiteUrl;
  final bool isCurated;
  final int priority;

  BrandEntity copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? tagline,
    String? story,
    String? websiteUrl,
    bool? isCurated,
    int? priority,
  }) {
    return BrandEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      tagline: tagline ?? this.tagline,
      story: story ?? this.story,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      isCurated: isCurated ?? this.isCurated,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    logoUrl,
    tagline,
    story,
    websiteUrl,
    isCurated,
    priority,
  ];
}
