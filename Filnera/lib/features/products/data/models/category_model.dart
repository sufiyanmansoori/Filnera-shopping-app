class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
  });

  final String id;
  final String name;
  final String slug;
  final String icon;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Category',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'icon': icon,
  };
}
