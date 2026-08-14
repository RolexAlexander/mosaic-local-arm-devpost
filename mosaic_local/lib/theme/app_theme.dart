import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Centralized Material 3 Theme configurations for Mosaic Local.
abstract final class AppTheme {
  /// Signature Obsidian Dark Theme matching banner.png & logo.png
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.iris,
      onPrimary: Colors.white,
      primaryContainer: AppColors.darkCardElevated,
      onPrimaryContainer: AppColors.darkTextPrimary,
      secondary: AppColors.coral,
      onSecondary: Colors.white,
      tertiary: AppColors.mint,
      onTertiary: Color(0xFF072719),
      surface: AppColors.darkCard,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: colorScheme,
      textTheme: AppTypography.createTextTheme(isDark: true),
      fontFamily: 'sans',

      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedXl,
          side: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),

      // Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        labelStyle: TextStyle(color: AppColors.darkTextSecondary),
        hintStyle: TextStyle(color: AppColors.darkTextMuted),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.roundedLg,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedLg,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedLg,
          borderSide: const BorderSide(color: AppColors.iris, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedLg,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.iris,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
          textStyle: AppTypography.button,
          disabledBackgroundColor: AppColors.darkCardElevated,
          disabledForegroundColor: AppColors.darkTextMuted,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          side: const BorderSide(color: AppColors.darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
          textStyle: AppTypography.button,
        ),
      ),

      // Navigation Bar Theme (Matching banner mockup)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkBackgroundSubtle,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.iris.withValues(alpha: 0.22),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.irisLight, size: 24);
          }
          return const IconThemeData(color: AppColors.darkTextMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            );
          }
          return const TextStyle(
            color: AppColors.darkTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          );
        }),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCardElevated,
        disabledColor: AppColors.darkCard,
        selectedColor: AppColors.iris.withValues(alpha: 0.25),
        secondarySelectedColor: AppColors.coral.withValues(alpha: 0.25),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedFull,
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        labelStyle: TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Dialog & Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkBackground,
        modalBackgroundColor: AppColors.darkBackground,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkCard,
        elevation: 16,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedXxl),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCardElevated,
        contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
        behavior: SnackBarBehavior.floating,
      ),

      // Slider Theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.mint,
        inactiveTrackColor: AppColors.darkCardElevated,
        thumbColor: AppColors.mint,
      ),
    );
  }

  /// Clean Studio Light Theme
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.iris,
      onPrimary: Colors.white,
      primaryContainer: AppColors.lightCardElevated,
      onPrimaryContainer: AppColors.lightTextPrimary,
      secondary: AppColors.coral,
      onSecondary: Colors.white,
      tertiary: AppColors.mintDark,
      onTertiary: Colors.white,
      surface: AppColors.lightCard,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: colorScheme,
      textTheme: AppTypography.createTextTheme(isDark: false),
      fontFamily: 'sans',

      cardTheme: const CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedXl,
          side: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        labelStyle: TextStyle(color: AppColors.lightTextSecondary),
        hintStyle: TextStyle(color: AppColors.lightTextMuted),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.roundedLg,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedLg,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedLg,
          borderSide: const BorderSide(color: AppColors.iris, width: 1.5),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.iris,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
          textStyle: AppTypography.button,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 2,
        height: 68,
        indicatorColor: AppColors.iris.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
    );
  }
}
