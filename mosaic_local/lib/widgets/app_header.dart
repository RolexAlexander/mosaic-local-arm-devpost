import 'package:flutter/material.dart';
import '../services/mosaic_engine.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'mosaic_logo_view.dart';

/// Top brand header matching the banner mockup with logo, title, on-device tagline,
/// and security/offline status badge.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.state,
    this.onTapStatus,
  });

  final EngineState state;
  final VoidCallback? onTapStatus;

  @override
  Widget build(BuildContext context) {
    final isReady = state == EngineState.ready;
    final isGenerating = state == EngineState.generating;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Brand Logo
          const MosaicLogoView(size: 38),
          const SizedBox(width: 12),

          // Brand Title and Tagline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Mosaic Local',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'All generation happens on device.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mint,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),

          // Security / Status Pill
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTapStatus,
              borderRadius: AppSpacing.roundedFull,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isReady
                      ? AppColors.mint.withValues(alpha: 0.12)
                      : isGenerating
                          ? AppColors.iris.withValues(alpha: 0.18)
                          : AppColors.amber.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.roundedFull,
                  border: Border.all(
                    color: isReady
                        ? AppColors.mint.withValues(alpha: 0.35)
                        : isGenerating
                            ? AppColors.iris.withValues(alpha: 0.45)
                            : AppColors.amber.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isReady
                          ? Icons.shield_outlined
                          : isGenerating
                              ? Icons.auto_awesome
                              : Icons.memory_rounded,
                      size: 14,
                      color: isReady
                          ? AppColors.mint
                          : isGenerating
                              ? AppColors.irisLight
                              : AppColors.amber,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isReady
                          ? '100% LOCAL'
                          : isGenerating
                              ? 'INFERENCING'
                              : 'SETUP',
                      style: AppTypography.badgeLabel.copyWith(
                        color: isReady
                            ? AppColors.mint
                            : isGenerating
                                ? AppColors.irisLight
                                : AppColors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
