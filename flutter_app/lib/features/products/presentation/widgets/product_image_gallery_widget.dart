import 'package:flutter/material.dart';

class ProductImageGalleryWidget extends StatelessWidget {
  const ProductImageGalleryWidget({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox(
        height: 260,
        child: Center(child: Icon(Icons.image_not_supported_outlined)),
      );
    }

    return SizedBox(
      height: 260,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          final image = images[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.image_not_supported_outlined)),
            ),
          );
        },
      ),
    );
  }
}
