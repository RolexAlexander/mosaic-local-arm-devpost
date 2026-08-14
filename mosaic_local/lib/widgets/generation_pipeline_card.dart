import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Animated inference progress card displaying live token generation and engine state.
class GenerationPipelineCard extends StatelessWidget {
  const GenerationPipelineCard({
    super.key,
    required this.stage,
    required this.preview,
  });

  final String stage;
  final String preview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppSpacing.roundedXl,
        border: Border.all(
          color: AppColors.iris.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: AppSpacing.irisGlowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: AppSpacing.roundedFull,
            child: const LinearProgressIndicator(
              minHeight: 5,
              color: AppColors.mint,
              backgroundColor: Color(0x26FFFFFF),
            ),
          ),
          const SizedBox(height: 16),

          // Stage Title
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stage.isNotEmpty ? stage : 'Running on Arm LiteRT-LM engine…',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ),
            ],
          ),

          if (preview.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Text(
                preview,
                maxLines: 4,
                overflow: TextOverflow.fade,
                style: AppTypography.code.copyWith(
                  color: AppColors.mintLight,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
