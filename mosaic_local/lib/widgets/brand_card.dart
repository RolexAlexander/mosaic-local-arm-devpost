import 'package:flutter/material.dart';
import '../domain/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Card showing current brand profile overview with quick edit action.
class BrandCard extends StatelessWidget {
  const BrandCard({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  final BrandProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final initial = profile.name.isNotEmpty
        ? profile.name.substring(0, 1).toUpperCase()
        : 'M';

    return Card(
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedXl,
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            // Brand Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.irisGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppSpacing.irisGlowShadow,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Profile info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          profile.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mint.withValues(alpha: 0.15),
                          borderRadius: AppSpacing.roundedFull,
                        ),
                        child: const Text(
                          'SAVED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.mint,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${profile.voice} • ${profile.region}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Edit button
            IconButton.filledTonal(
              onPressed: onEdit,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.darkCardElevated,
                foregroundColor: AppColors.darkTextPrimary,
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
