import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/app_data.dart';

class AppTheme {
  AppTheme._();

  // Preset Apple Journal Pastel Colors
  static const List<String> pastelColorsHex = [
    '#B8A9F8', // Lavender
    '#8EC89A', // Sage
    '#F8B182', // Peach
    '#85CDFD', // Sky Blue
    '#F699B4', // Rose Pink
    '#EAC864', // Buttercup
    '#D0A2E2', // Lilac
    '#7DD7C8', // Mint Teal
  ];

  // Apple Journal Colors
  static const Color darkBackground = Color(0xFF0F1015);
  static const Color darkCard = Color(0xFF1A1C24);
  static const Color lightBackground = Color(0xFFF3F4F7);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Material 3 Colors
  static const Color m3SeedColor = Color(0xFF6750A4);

  static Color cardBackground(
    BuildContext context, {
    Color? accentColor,
    AppVisualTheme? visualTheme,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isM3 = visualTheme == AppVisualTheme.material3;

    if (isM3) {
      final base = isDark
          ? const Color(0xFF211F26)
          : const Color(0xFFF7F2FA);
      if (accentColor == null) return base;
      return Color.alphaBlend(
        accentColor.withValues(alpha: isDark ? 0.16 : 0.14),
        base,
      );
    }

    final base = isDark ? darkCard : lightCard;
    if (accentColor == null) return base;
    return Color.alphaBlend(
      accentColor.withValues(alpha: isDark ? 0.14 : 0.12),
      base,
    );
  }

  static BorderRadius cardRadius({AppVisualTheme? visualTheme}) {
    if (visualTheme == AppVisualTheme.material3) {
      return BorderRadius.circular(18);
    }
    return BorderRadius.circular(22);
  }

  static Border cardBorder(
    BuildContext context, {
    Color? accentColor,
    AppVisualTheme? visualTheme,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isM3 = visualTheme == AppVisualTheme.material3;

    if (isM3) {
      if (accentColor != null) {
        return Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.35 : 0.28),
          width: 1.0,
        );
      }
      return Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.08),
        width: 1.0,
      );
    }

    if (accentColor != null) {
      return Border.all(
        color: accentColor.withValues(alpha: isDark ? 0.32 : 0.22),
        width: 1.0,
      );
    }
    return Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
      width: 1.0,
    );
  }

  static List<BoxShadow> cardShadow(
    BuildContext context, {
    AppVisualTheme? visualTheme,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isM3 = visualTheme == AppVisualTheme.material3;

    if (isM3) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ];
  }

  // Apple Journal Themes
  static ThemeData get appleJournalLight {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8B78E6),
        brightness: Brightness.light,
        surface: lightCard,
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF8B78E6),
      ),
    );
  }

  static ThemeData get appleJournalDark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFB8A9F8),
        brightness: Brightness.dark,
        surface: darkCard,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFB8A9F8),
      ),
    );
  }

  // Material 3 Themes
  static ThemeData get material3Light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: m3SeedColor,
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  static ThemeData get material3Dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: m3SeedColor,
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
