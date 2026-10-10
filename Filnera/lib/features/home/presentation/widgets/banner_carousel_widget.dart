import 'package:flutter/material.dart';

import '../../domain/entities/banner_entity.dart';

class BannerCarouselWidget extends StatelessWidget {
  const BannerCarouselWidget({super.key, required this.banners});

  final List<BannerEntity> banners;

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: banner.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(banner.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: banner.imageUrl.isEmpty
                ? const Center(child: Icon(Icons.image))
                : null,
          );
        },
      ),
    );
  }
}
