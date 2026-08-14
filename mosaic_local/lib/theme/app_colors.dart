import 'package:flutter/material.dart';

/// Semantic brand color tokens for Mosaic Local, directly aligned with
/// the visual identity in logo.png and banner.png.
abstract final class AppColors {
  // Brand Triad (from logo & mockup cards)
  static const Color iris = Color(0xFF6342F5);
  static const Color irisLight = Color(0xFF8A70FF);
  static const Color irisDark = Color(0xFF482AC9);
  static const Color irisGlow = Color(0x336342F5);

  static const Color coral = Color(0xFFFF5537);
  static const Color coralLight = Color(0xFFFF7F68);
  static const Color coralDark = Color(0xFFD63B1E);
  static const Color coralGlow = Color(0x33FF5537);

  static const Color mint = Color(0xFF7AE0B5);
  static const Color mintLight = Color(0xFFA3F0D1);
  static const Color mintDark = Color(0xFF4DBB8E);
  static const Color mintGlow = Color(0x337AE0B5);

  static const Color amber = Color(0xFFFFB03A);
  static const Color amberLight = Color(0xFFFFCC7A);

  // Dark Theme Palette (Obsidian & Space)
  static const Color darkBackground = Color(0xFF0D0F17);
  static const Color darkBackgroundSubtle = Color(0xFF131622);
  static const Color darkCard = Color(0xFF191D2B);
  static const Color darkCardElevated = Color(0xFF222738);
  static const Color darkCardHighlight = Color(0xFF2B3248);
  static const Color darkBorder = Color(0x1AFFFFFF);
  static const Color darkBorderHighlight = Color(0x33FFFFFF);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Theme Palette (Crisp & Clean Studio)
  static const Color lightBackground = Color(0xFFF5F7FB);
  static const Color lightBackgroundSubtle = Color(0xFFECEFF5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF1F5F9);
  static const Color lightCardHighlight = Color(0xFFE2E8F0);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderHighlight = Color(0xFFCBD5E1);

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Status Colors
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [iris, coral, mint],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient irisGradient = LinearGradient(
    colors: [Color(0xFF7555FA), Color(0xFF5233E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFFF694D), Color(0xFFE84223)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFF8CEAC3), Color(0xFF56CAA1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
