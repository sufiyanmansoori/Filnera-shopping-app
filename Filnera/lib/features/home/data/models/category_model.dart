
class CategoryModel {
  const CategoryModel({required this.name, this.imageUrl});

  final String? name;
  final String? imageUrl;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
