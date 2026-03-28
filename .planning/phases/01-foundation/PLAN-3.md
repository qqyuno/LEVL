# Plan 1.3 — ThemeData + AppColors + Typography

**Phase:** 1 — Foundation
**Goal:** Полная дизайн-система Flutter: цвета, типографика, ThemeData.

## Files to Create

### `lib/core/theme/app_colors.dart`
```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // Backgrounds
  static const background = Color(0xFFF8F8F6);
  static const surface = Color(0xFFE2E2DE);

  // Text
  static const textPrimary = Color(0xFF0A0A0A);
  static const textSecondary = Color(0xFF6B6B67);

  // Brand
  static const gold = Color(0xFFB8962E); // EARNED ONLY — never decorative

  // Functional
  static const divider = Color(0xFFE2E2DE);
  static const white = Color(0xFFFFFFFF);
}
```

### `lib/core/theme/app_typography.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  // DM Serif Display — headers, levels, logo
  static TextStyle displayLarge = GoogleFonts.dmSerifDisplay(
    fontSize: 40,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static TextStyle displayMedium = GoogleFonts.dmSerifDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle displaySmall = GoogleFonts.dmSerifDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // DM Sans — all UI text
  static TextStyle bodyLarge = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle labelLarge = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle caption = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
```

### `lib/core/theme/app_theme.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.gold,
      onPrimary: AppColors.white,
      secondary: AppColors.textPrimary,
      onSecondary: AppColors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
      error: Color(0xFFB00020),
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    dividerColor: AppColors.divider,
    textTheme: GoogleFonts.dmSansTextTheme().copyWith(
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      displaySmall: AppTypography.displaySmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      labelLarge: AppTypography.labelLarge,
      bodySmall: AppTypography.caption,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.displaySmall,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        textStyle: AppTypography.labelLarge,
      ),
    ),
  );
}
```

## Steps
1. Создать `lib/core/theme/app_colors.dart`
2. Создать `lib/core/theme/app_typography.dart`
3. Создать `lib/core/theme/app_theme.dart`
4. Подключить `AppTheme.light` в `main.dart`

## Verification
- [ ] Все 3 файла созданы
- [ ] Gold цвет (#B8962E) только в AppColors.gold
- [ ] DM Serif Display используется для displayLarge/Medium/Small
- [ ] DM Sans используется для body/label
- [ ] `AppTheme.light` компилируется без ошибок
