import 'package:flutter/material.dart';

// ============ COLOR PALETTE ============
class AppColors {
  // Primary palette (as per requirement)
  static const Color primary = Color(0xFF2A8DF0);
  static const Color warning = Color(0xFFFFCC00);
  static const Color success = Color(0xFF3FFF78);
  static const Color danger = Color(0xFFFF0000);
  static const Color secondary = Color(0xFFEDF3FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF000000);
  static const Color grey = Color(0xFFF2F4FA);
  static const Color blueGrey = Color(0xFF8FABD4);
  static const Color lightGrey = Color(0xFFA6A9AF);

  // Extended palette (project-specific colors mapped to primary palette)
  static const Color darkBg = Color(0xFF0F0F0F); // Main app background
  static const Color darkSurface = Color(0xFF1A1A1A); // Cards, app bars
  static const Color accent = primary;
  static const Color favorite = Color(0xFFFF173A);

  // Text color variants
  static const Color textPrimary = white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);
  static const Color textHint = Color(0xFF666666);

  // Border & divider colors
  static const Color divider = Color(0xFF2A2A2A);
  static const Color border = Color(0xFF3A3A3A);

  // Status colors
  static const Color error = danger;
  static const Color info = primary;
}

// ============ TEXT STYLES ============
class AppTextStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(
    color: AppColors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    color: AppColors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    color: AppColors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle heading4 = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );

  // Body text styles
  static const TextStyle bodyLarge = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Label text styles
  static const TextStyle labelLarge = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // Secondary text styles
  static const TextStyle textSecondary = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle textTertiary = TextStyle(
    color: AppColors.textTertiary,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // Hint text style
  static const TextStyle hint = TextStyle(
    color: AppColors.textHint,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // Caption styles
  static const TextStyle caption = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );

  // Dark text style (for light backgrounds)
  static const TextStyle darkTextStyle = TextStyle(
    color: AppColors.dark,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Light text style (for dark backgrounds)
  static const TextStyle lightTextStyle = TextStyle(
    color: AppColors.white,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
}
