import 'package:flutter/material.dart';
import '../domain/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Social Copy module card styled after the banner mockup.
class SocialCopyCard extends StatelessWidget {
  const SocialCopyCard({
    super.key,
    this.post,
    this.brand,
    this.onTap,
  });

  final CampaignPost? post;
  final BrandProfile? brand;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final previewText = post != null
        ? '${post!.hook}\n${post!.caption}'
        : 'Elevate your everyday.\nThoughtfully made.\nNaturally better.';

    final toneLabel = brand != null ? 'Tone: ${brand!.voice}' : 'Tone: Warm';

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
                  // Radiant Coral Message Bubble Squircle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.coralGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppSpacing.coralGlowShadow,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & Preview
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SOCIAL COPY',
                          style: AppTypography.sectionHeader.copyWith(
                            color: AppColors.coralLight,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          previewText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkTextPrimary,
                            height: 1.3,
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

              // Module Chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  const _CopyChip(label: 'Short-form'),
                  _CopyChip(label: post != null ? 'Pillar: ${post!.pillar}' : 'Variation A'),
                  _CopyChip(label: toneLabel, highlight: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CopyChip extends StatelessWidget {
  const _CopyChip({required this.label, this.highlight = false});
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.darkCardElevated,
        borderRadius: AppSpacing.roundedFull,
        border: Border.all(
          color: highlight
              ? AppColors.coral.withValues(alpha: 0.35)
              : AppColors.darkBorder,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: highlight ? AppColors.coralLight : AppColors.darkTextSecondary,
        ),
      ),
    );
  }
}
