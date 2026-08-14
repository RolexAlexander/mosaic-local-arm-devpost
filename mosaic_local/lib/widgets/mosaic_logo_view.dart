import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Renders the Mosaic Local brand logo mark.
/// Uses the asset image if available, with a stylish geometric fallback.
class MosaicLogoView extends StatelessWidget {
  const MosaicLogoView({
    super.key,
    this.size = 38,
    this.showBackground = false,
  });

  final double size;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _FallbackLogo(size: size),
    );

    if (!showBackground) return imageWidget;

    return Container(
      width: size + 10,
      height: size + 10,
      decoration: BoxDecoration(
        color: AppColors.darkCardElevated,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.darkBorder),
      ),
      padding: const EdgeInsets.all(5),
      child: imageWidget,
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.irisGradient,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: AppSpacing.irisGlowShadow,
      ),
      child: Center(
        child: Icon(
          Icons.hub_rounded,
          size: size * 0.58,
          color: Colors.white,
        ),
      ),
    );
  }
}
