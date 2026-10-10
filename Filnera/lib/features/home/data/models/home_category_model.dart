import '../../domain/entities/home_data_entity.dart';

class HomeCategoryModel {
  const HomeCategoryModel({
    required this.id,
    required this.name,
    this.imageUrl = '',
    this.slug = '',
    this.description,
    this.parentId,
    this.isActive = true,
    this.subcategoryCount = 0,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String slug;
  final String? description;
  final String? parentId;
  final bool isActive;
  final int subcategoryCount;

  factory HomeCategoryModel.fromJson(Map<String, dynamic> json) {
    return HomeCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Category',
      imageUrl:
          json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      parentId: json['parent_id']?.toString() ?? json['parentId']?.toString(),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      subcategoryCount:
          int.tryParse(json['subcategory_count']?.toString() ?? '0') ??
          int.tryParse(json['subcategoryCount']?.toString() ?? '0') ??
          0,
    );
  }

  factory HomeCategoryModel.fromEntity(HomeCategoryEntity entity) {
    return HomeCategoryModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl ?? '',
      slug: entity.slug,
      description: entity.description,
      parentId: entity.parentId,
      isActive: entity.isActive,
      subcategoryCount: entity.subcategoryCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image_url': imageUrl,
    'slug': slug,
    'description': description,
    'parent_id': parentId,
    'is_active': isActive,
    'subcategory_count': subcategoryCount,
  };

  HomeCategoryEntity toEntity() => HomeCategoryEntity(
    id: id,
    name: name,
    slug: slug,
    imageUrl: imageUrl,
    parentId: parentId,
    description: description,
    isActive: isActive,
    subcategoryCount: subcategoryCount,
  );
}
