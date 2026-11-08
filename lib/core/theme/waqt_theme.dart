import 'package:flutter/material.dart';

import 'tokens.dart';

const _tabular = [FontFeature.tabularFigures()];

// Bricolage Grotesque, a variable font: weight, and an optical size that
// matches the text size so the big clock gets its display cut.
TextStyle _display(double size, {double weight = 800, double tracking = -0.03}) => TextStyle(
  fontFamily: WaqtFonts.display,
  fontSize: size,
  fontVariations: [FontVariation('wght', weight), FontVariation('opsz', size.clamp(12, 96).toDouble())],
  fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
  letterSpacing: size * tracking,
  height: 1.05,
  fontFeatures: _tabular,
  fontFamilyFallback: WaqtFonts.fallback,
);

TextStyle _body(double size, double weight, {double height = 1.4}) => TextStyle(
  fontFamily: WaqtFonts.body,
  fontSize: size,
  fontVariations: [FontVariation('wght', weight)],
  fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
  height: height,
  fontFeatures: _tabular,
  fontFamilyFallback: WaqtFonts.fallback,
);

/// Everything the UI needs that Material's ColorScheme doesn't express.
@immutable
class WaqtTokens extends ThemeExtension<WaqtTokens> {
  const WaqtTokens({
    required this.ground,
    required this.ink,
    required this.accent,
    required this.inkMuted,
    required this.hairline,
    required this.surface,
    required this.heroSurface,
    required this.heroInk,
  });

  factory WaqtTokens.fromPalette(MomentPalette p) {
    final ink = p.ink;
    return WaqtTokens(
      ground: p.ground,
      ink: ink,
      accent: p.accent,
      // 68% ink keeps ≥ 4.5:1 on every palette ground (checked in tests).
      inkMuted: ink.withValues(alpha: 0.68),
      hairline: ink.withValues(alpha: 0.08),
      surface: Color.alphaBlend(ink.withValues(alpha: p.isDark ? 0.06 : 0.035), p.ground),
      heroSurface: p.isDark ? Color.alphaBlend(ink.withValues(alpha: 0.09), p.ground) : ink,
      heroInk: p.isDark ? ink : p.ground,
    );
  }

  final Color ground;
  final Color ink;
  final Color accent;
  final Color inkMuted;
  final Color hairline;
  final Color surface;
  final Color heroSurface;
  final Color heroInk;

  /// `0 0 0 1px ink@6%` + soft blur.
  List<BoxShadow> get rest => [
    BoxShadow(color: ink.withValues(alpha: 0.06), spreadRadius: 1),
    BoxShadow(color: ink.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
  ];

  /// Hero card: a hairline edge, no glow.
  List<BoxShadow> get hero => [BoxShadow(color: ink.withValues(alpha: 0.08), spreadRadius: 1)];

  static WaqtTokens of(BuildContext context) => Theme.of(context).extension<WaqtTokens>()!;

  @override
  WaqtTokens copyWith() => this;

  @override
  WaqtTokens lerp(WaqtTokens? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return WaqtTokens(
      ground: l(ground, other.ground),
      ink: l(ink, other.ink),
      accent: l(accent, other.accent),
      inkMuted: l(inkMuted, other.inkMuted),
      hairline: l(hairline, other.hairline),
      surface: l(surface, other.surface),
      heroSurface: l(heroSurface, other.heroSurface),
      heroInk: l(heroInk, other.heroInk),
    );
  }
}

abstract final class WaqtText {
  static TextStyle get clock => _display(64, tracking: -0.04);
  static TextStyle get title => _display(26);
  static TextStyle get titleSmall => _display(20, weight: 760, tracking: -0.025);
  static TextStyle get body => _body(15, 420);
  static TextStyle get bodyStrong => _body(15, 580);
  static TextStyle get label => _body(13, 540, height: 1.3);
  static TextStyle get caption => _body(12, 500, height: 1.3);
  static TextStyle get overline => _body(11, 620, height: 1.2).copyWith(letterSpacing: 0.6);
  static const arabic = TextStyle(fontFamily: WaqtFonts.arabic, fontSize: 30, height: 1.65);
}

ThemeData buildWaqtTheme(MomentPalette palette) {
  final t = WaqtTokens.fromPalette(palette);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: palette.accent,
        brightness: palette.isDark ? Brightness.dark : Brightness.light,
      ).copyWith(
        surface: palette.ground,
        onSurface: palette.ink,
        primary: palette.ink,
        onPrimary: palette.ground,
        secondary: palette.accent,
        outline: t.hairline,
      );

  TextStyle c(TextStyle s) => s.copyWith(color: palette.ink);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.ground,
    fontFamily: WaqtFonts.body,
    splashFactory: InkSparkle.splashFactory,
    extensions: [t],
    textTheme: TextTheme(
      displayLarge: c(WaqtText.clock),
      headlineSmall: c(WaqtText.title),
      titleMedium: c(WaqtText.titleSmall),
      bodyLarge: c(WaqtText.body),
      bodyMedium: c(WaqtText.body),
      labelLarge: c(WaqtText.label),
      labelSmall: c(WaqtText.caption),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.ground,
      surfaceTintColor: Colors.transparent,
      indicatorColor: t.ink.withValues(alpha: 0.08),
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(size: 22, color: s.contains(WidgetState.selected) ? t.ink : t.inkMuted),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => WaqtText.caption.copyWith(color: s.contains(WidgetState.selected) ? t.ink : t.inkMuted),
      ),
    ),
    dividerTheme: DividerThemeData(color: t.hairline, thickness: 1, space: 1),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
    ),
  );
}
