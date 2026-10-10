import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';

class CategorySectionWidget extends StatelessWidget {
  const CategorySectionWidget({super.key, required this.categories});

  final List<HomeCategoryEntity> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 104,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: const Icon(Icons.category_outlined),
                ),
                const SizedBox(height: 8),
                Text(category.name, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }
}
