import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/user_profile_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile, this.onEditTap});

  final UserProfileModel profile;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5E8), Color(0xFFF4F8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            alignment: Alignment.center,
            child: profile.avatarUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      profile.avatarUrl,
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallbackAvatar(profile),
                    ),
                  )
                : _fallbackAvatar(profile),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statusChip(
                      profile.emailVerified ? 'Verified' : 'Unverified',
                      profile.emailVerified
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    _statusChip(
                      profile.city.isEmpty ? 'Set location' : profile.city,
                      AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onEditTap != null)
            IconButton(
              onPressed: onEditTap,
              icon: const Icon(Icons.edit_outlined),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar(UserProfileModel profile) {
    return Text(
      profile.initials,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
