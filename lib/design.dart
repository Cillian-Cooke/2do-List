import 'package:flutter/material.dart';

/// ===========================================================================
///  APP DESIGN
///  ---------------------------------------------------------------------------
///  This is the ONE place to restyle the whole app. Change a value here and it
///  updates everywhere — background, buttons, fonts, spacing, corner rounding,
///  and the pink / blue / purple owner colors shown on the list and calendar.
///
///  Nothing else in the app hardcodes a color, radius, or size: every widget
///  reads from here. Grouped top-to-bottom as:
///     1. Colors        2. Owner colors    3. Importance colors
///     4. Typography    5. Shape (corners) 6. Spacing   7. Opacities
///     8. buildTheme()  — turns the values above into the app's ThemeData.
/// ===========================================================================
class AppDesign {
  AppDesign._();

  // ---------------------------------------------------------------------------
  // 1. COLORS
  // ---------------------------------------------------------------------------

  /// Seed the whole Material color scheme is generated from (accents, ripples,
  /// the "today" ring on the calendar, etc.).
  static const Color seedColor = Color(0xFF00897B); // teal

  /// The page background behind everything.
  static const Color background = Color(0xFFFFF7FA); // barely-pink white

  /// Card / sheet / surface color.
  static const Color surface = Colors.white;

  /// Destructive actions — the swipe-to-delete background.
  static const Color danger = Color(0xFFE53935); // red

  /// Whether the app renders in light or dark. Flip to [Brightness.dark] for a
  /// dark theme (also darken [background] / [surface] above to match).
  static const Brightness brightness = Brightness.light;

  // ---------------------------------------------------------------------------
  // 2. OWNER COLORS  (multi-user shell — "you", your partner, and shared)
  // ---------------------------------------------------------------------------

  static const Color meColor = Color(0xFFEC407A); // pink   — you
  static const Color partnerColor = Color(0xFF42A5F5); // blue   — your partner
  static const Color sharedColor = Color(0xFFAB47BC); // purple — shared

  // ---------------------------------------------------------------------------
  // 3. IMPORTANCE COLORS  (the little pill on each entry)
  // ---------------------------------------------------------------------------

  static const Color importanceLow = Color(0xFF43A047); // green
  static const Color importanceMedium = Color(0xFFB8860B); // amber
  static const Color importanceHigh = Color(0xFFE53935); // red

  // ---------------------------------------------------------------------------
  // 4. TYPOGRAPHY
  // ---------------------------------------------------------------------------

  /// Font family for the whole app. `null` uses the platform default (Roboto on
  /// Android). Set to a family you've added under `fonts:` in pubspec.yaml to
  /// re-skin every piece of text at once.
  static const String? fontFamily = null;

  static const double titleSize = 20;
  static const double entryTitleSize = 16;
  static const double bodySize = 14;
  static const double captionSize = 12;

  static const FontWeight entryTitleWeight = FontWeight.w600;

  // ---------------------------------------------------------------------------
  // 5. SHAPE  (corner rounding)
  // ---------------------------------------------------------------------------

  static const double radiusSmall = 8; // calendar day cells, inner taps
  static const double radiusCard = 12; // entry cards, badges
  static const double radiusButton = 14; // the big "Add to timeline" button
  static const double radiusSheet = 24; // bottom-sheet top corners

  // ---------------------------------------------------------------------------
  // 6. SPACING
  // ---------------------------------------------------------------------------

  static const double gap = 8;
  static const double gapLarge = 16;
  static const double screenPadding = 16;

  // ---------------------------------------------------------------------------
  // 7. OPACITIES  (how strongly colors tint backgrounds / dim when done)
  // ---------------------------------------------------------------------------

  /// Applied to an owner color to tint a card's background.
  static const double cardTint = 0.06;

  /// Applied to an entry's color once it's ticked off (fades it out).
  static const double doneFade = 0.45;

  /// Importance-pill fill and border strength.
  static const double badgeFill = 0.15;
  static const double badgeBorder = 0.40;

  // ---------------------------------------------------------------------------
  // 8. THEME  — assembled from everything above. Wired up in main.dart.
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
