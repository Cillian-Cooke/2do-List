import 'package:flutter/material.dart';

/// ===========================================================================
///  APP DESIGN
///  ---------------------------------------------------------------------------
///  This is the ONE place to restyle the whole app. Change a value here and it
///  updates everywhere — background, glass tints, fonts, spacing, corners.
///
///  Owner language on the day board:
///     You (blue glass)  ·  Partner (red glass)  ·  Group (green glass)
///  Blue + red acetate stacks into purple, so overlapping to-do sheets read
///  as layered panes, not as three separate apps.
/// ===========================================================================
class AppDesign {
  AppDesign._();

  // ---------------------------------------------------------------------------
  // 1. COLORS
  // ---------------------------------------------------------------------------

  static const Color seedColor = Color(0xFF3B6FE0);

  /// Warm paper behind the day board.
  static const Color background = Color(0xFFF3EDE3);

  /// Stickers, cards, calendar cells.
  static const Color surface = Color(0xFFFFFBF4);

  static const Color paperLine = Color(0xFFD9D0C3);

  static const Color danger = Color(0xFFE53935);

  static const Brightness brightness = Brightness.light;

  // ---------------------------------------------------------------------------
  // 2. OWNER / GLASS COLORS
  // ---------------------------------------------------------------------------

  static const Color meColor = Color(0xFF2F6BFF); // blue  — you
  static const Color partnerColor = Color(0xFFE23B4A); // red   — partner
  static const Color sharedColor = Color(0xFF1EA86A); // green — group

  static const double glassBlur = 28;
  static const double glassTint = 0.20;
  static const double glassHighlight = 0.34;
  static const double stackedTint = 0.36;
  static const double glassInset = 14;
  static const double glassPeek = 0.12;

  /// How far from a screen edge a swipe has to start to pull a sheet in.
  static const double edgeHit = 40;

  static const double stickerTilt = 0.12;

  // ---------------------------------------------------------------------------
  // 3. IMPORTANCE COLORS
  // ---------------------------------------------------------------------------

  static const Color importanceLow = Color(0xFF43A047);
  static const Color importanceMedium = Color(0xFFB8860B);
  static const Color importanceHigh = Color(0xFFE53935);

  // ---------------------------------------------------------------------------
  // 4. TYPOGRAPHY
  // ---------------------------------------------------------------------------

  static const String? fontFamily = null;

  static const double titleSize = 20;
  static const double entryTitleSize = 16;
  static const double bodySize = 14;
  static const double captionSize = 12;

  static const FontWeight entryTitleWeight = FontWeight.w600;

  // ---------------------------------------------------------------------------
  // 5. SHAPE
  // ---------------------------------------------------------------------------

  static const double radiusSmall = 8;
  static const double radiusCard = 12;
  static const double radiusButton = 14;
  static const double radiusSheet = 24;
  static const double radiusGlass = 38;
  static const double radiusSticker = 14;

  // ---------------------------------------------------------------------------
  // 6. SPACING
  // ---------------------------------------------------------------------------

  static const double gap = 8;
  static const double gapLarge = 16;
  static const double screenPadding = 16;
  static const double timetableWidth = 118;
  static const double groupStripHeight = 96;
  static const double calendarHeight = 272;

  // ---------------------------------------------------------------------------
  // 7. OPACITIES
  // ---------------------------------------------------------------------------

  static const double cardTint = 0.10;
  static const double doneFade = 0.45;
  static const double badgeFill = 0.15;
  static const double badgeBorder = 0.40;

  // ---------------------------------------------------------------------------
  // 8. THEME
  // ---------------------------------------------------------------------------

  static ThemeData buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ).copyWith(surface: surface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
    );
  }
}
