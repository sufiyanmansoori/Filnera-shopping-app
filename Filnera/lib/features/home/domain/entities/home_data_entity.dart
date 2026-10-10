import 'package:equatable/equatable.dart';

import 'banner_entity.dart';
import 'deal_entity.dart';
import 'featured_product_entity.dart';
import 'flash_sale_entity.dart';
import 'recommendation_entity.dart';
import 'section_entity.dart';

/// Aggregate of all home content fetched from the backend for a single page.
class HomeDataEntity extends Equatable {
  const HomeDataEntity({
    required this.banners,
    required this.categories,
    required this.deals,
    required this.featuredProducts,
    required this.flashSales,
    required this.recommendations,
    required this.trendingProducts,
    required this.sections,
    this.personalizedSummary,
    this.lastUpdated,
  });

  final List<BannerEntity> banners;
  final List<HomeCategoryEntity> categories;
  final List<DealEntity> deals;
  final List<FeaturedProductEntity> featuredProducts;
  final List<FlashSaleEntity> flashSales;
  final List<RecommendationEntity> recommendations;
  final List<FeaturedProductEntity> trendingProducts;
  final List<SectionEntity> sections;
  final String? personalizedSummary;
  final DateTime? lastUpdated;

  bool get hasContent =>
      banners.isNotEmpty ||
      categories.isNotEmpty ||
      deals.isNotEmpty ||
      featuredProducts.isNotEmpty ||
      flashSales.isNotEmpty ||
      recommendations.isNotEmpty ||
      trendingProducts.isNotEmpty ||
      sections.isNotEmpty;

  HomeDataEntity copyWith({
    List<BannerEntity>? banners,
    List<HomeCategoryEntity>? categories,
    List<DealEntity>? deals,
    List<FeaturedProductEntity>? featuredProducts,
    List<FlashSaleEntity>? flashSales,
    List<RecommendationEntity>? recommendations,
    List<FeaturedProductEntity>? trendingProducts,
    List<SectionEntity>? sections,
    String? personalizedSummary,
    DateTime? lastUpdated,
  }) {
    return HomeDataEntity(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      deals: deals ?? this.deals,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      flashSales: flashSales ?? this.flashSales,
      recommendations: recommendations ?? this.recommendations,
      trendingProducts: trendingProducts ?? this.trendingProducts,
      sections: sections ?? this.sections,
      personalizedSummary: personalizedSummary ?? this.personalizedSummary,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    banners,
    categories,
    deals,
    featuredProducts,
    flashSales,
    recommendations,
    trendingProducts,
    sections,
    personalizedSummary,
    lastUpdated,
  ];
}

class HomeCategoryEntity extends Equatable {
  const HomeCategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    this.parentId,
    this.description,
    this.isActive = true,
    this.subcategoryCount = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String? imageUrl;
  final String? parentId;
  final String? description;
  final bool isActive;
  final int subcategoryCount;

  HomeCategoryEntity copyWith({
    String? id,
    String? name,
    String? slug,
    String? imageUrl,
    String? parentId,
    String? description,
    bool? isActive,
    int? subcategoryCount,
  }) {
    return HomeCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      imageUrl: imageUrl ?? this.imageUrl,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      subcategoryCount: subcategoryCount ?? this.subcategoryCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    imageUrl,
    parentId,
    description,
    isActive,
    subcategoryCount,
  ];
}
