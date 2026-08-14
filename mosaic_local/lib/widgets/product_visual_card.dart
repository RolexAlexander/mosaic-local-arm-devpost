import 'dart:io';
import 'package:flutter/material.dart';
import '../domain/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Product Visual module card styled after the banner mockup.
class ProductVisualCard extends StatelessWidget {
  const ProductVisualCard({
    super.key,
    this.post,
    this.onTap,
  });

  final CampaignPost? post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final imagePath = post?.imagePath;
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return Card(
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedXl,
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.roundedXl,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Neo Mint Photo Squircle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.mintGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppSpacing.mintGlowShadow,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_rounded,
                        color: Color(0xFF0C2B1D),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRODUCT VISUAL',
                          style: AppTypography.sectionHeader.copyWith(
                            color: AppColors.mint,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasImage
                              ? 'Generated on device'
                              : (post != null
                                  ? post!.visual
                                  : 'Generated on device'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Trailing chevron
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.darkTextMuted,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Visual preview container
              ClipRRect(
                borderRadius: AppSpacing.roundedLg,
                child: hasImage
                    ? Image.file(
                        File(imagePath),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.darkCardElevated,
                          borderRadius: AppSpacing.roundedLg,
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome_outlined,
                              size: 28,
                              color: AppColors.mint.withValues(alpha: 0.8),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              post != null
                                  ? 'Tap to generate 512x512 visual on Arm'
                                  : 'Visual Creative Studio ready',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
