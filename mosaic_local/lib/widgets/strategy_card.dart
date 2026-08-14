import 'package:flutter/material.dart';
import '../domain/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Strategy module card styled after the banner mockup.
class StrategyCard extends StatelessWidget {
  const StrategyCard({
    super.key,
    this.campaign,
    this.brand,
    this.onTap,
  });

  final Campaign? campaign;
  final BrandProfile? brand;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = campaign != null
        ? campaign!.strategy
        : (brand != null
            ? '${brand!.audience} • ${brand!.voice} positioning'
            : 'Audience insights\nValue proposition');

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
                  // Royal Iris Bullseye Squircle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.irisGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppSpacing.irisGlowShadow,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.track_changes_rounded,
                        color: Colors.white,
                        size: 24,
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
                          'STRATEGY',
                          style: AppTypography.sectionHeader.copyWith(
                            color: AppColors.irisLight,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 2,
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
                  _Chip(label: 'Audience', active: brand != null),
                  _Chip(label: 'Positioning', active: campaign != null),
                  _Chip(label: 'Goals', active: brand?.goal != null),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.active = false});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.darkCardElevated,
        borderRadius: AppSpacing.roundedFull,
        border: Border.all(
          color: active
              ? AppColors.iris.withValues(alpha: 0.35)
              : AppColors.darkBorder,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: active ? AppColors.darkTextPrimary : AppColors.darkTextSecondary,
        ),
      ),
    );
  }
}
