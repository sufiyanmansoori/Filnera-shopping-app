import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class PromotionalBanner extends StatelessWidget {
  const PromotionalBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.backgroundColor,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundColor ?? AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
