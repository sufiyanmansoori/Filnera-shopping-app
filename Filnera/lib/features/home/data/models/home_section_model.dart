class HomeSectionModel {
  const HomeSectionModel({
    required this.type,
    required this.title,
    required this.items,
  });

  final String type;
  final String title;
  final List<dynamic> items;

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    return HomeSectionModel(
      type: json['type']?.toString() ?? 'section',
      title: json['title']?.toString() ?? 'Section',
      items: json['items'] is List
          ? List<dynamic>.from(json['items'])
          : const <dynamic>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    'items': items,
  };
}
