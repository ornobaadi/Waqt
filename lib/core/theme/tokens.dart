import 'package:flutter/animation.dart';

/// Moment palettes from design.md. The moment drives ground, ink and accent;
/// the layout never changes.
enum MomentPalette {
  fajr(ground: Color(0xFFF7EDE8), ink: Color(0xFF2A1A16), accent: Color(0xFFE9B9A0)),
  dhuhr(ground: Color(0xFFF8F4E8), ink: Color(0xFF1E1810), accent: Color(0xFFE6C66A)),
  asr(ground: Color(0xFFF6F1E7), ink: Color(0xFF1E1810), accent: Color(0xFFE8A54B)),
  maghrib(ground: Color(0xFF2A1416), ink: Color(0xFFFBEDE6), accent: Color(0xFFE07A5F)),
  night(ground: Color(0xFF0A0E26), ink: Color(0xFFE8EBFF), accent: Color(0xFF9FB3FF)),
  bedtime(ground: Color(0xFF17122A), ink: Color(0xFFEEE8FA), accent: Color(0xFFC9B8F0));

  const MomentPalette({required this.ground, required this.ink, required this.accent});

  final Color ground;
  final Color ink;
  final Color accent;

  bool get isDark => ground.computeLuminance() < 0.2;
}

/// Radii are concentric: inner = outer − padding.
abstract final class WaqtRadii {
  static const double row = 14;
  static const double strip = 18;
  static const double card = 24;
}

/// 4-pt grid.
abstract final class WaqtSpace {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x12 = 48;

  static const double screen = 20;
  static const double minTouch = 48;
}

abstract final class WaqtMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration ui = Duration(milliseconds: 260);

  /// Crossfade between moment palettes.
  static const Duration palette = Duration(milliseconds: 750);
  static const Curve ease = Cubic(0.2, 0, 0, 1);
}

abstract final class WaqtFonts {
  static const String display = 'BricolageGrotesque';
  static const String body = 'Inter';
  static const String arabic = 'NotoNaskhArabic';

  /// Quran text: Amiri Quran (OFL), drawn for the Uthmani script and ayah marks.
  static const String quran = 'AmiriQuran';

  /// DigitalKhatt IndoPak (OFL), for the IndoPak script.
  static const String indoPak = 'IndoPak';

  /// Instrument Serif italic (OFL): the welcome greeting only.
  static const String greeting = 'InstrumentSerif';
  static const String urdu = 'NotoNastaliqUrdu';
  static const String bengali = 'AnekBangla';

  /// Script fallback for UI text, chosen per locale (see [forLocale]).
  /// Urdu must reach Nastaliq before Naskh, since both cover Arabic script.
  static List<String> fallback = const [arabic, bengali, urdu];

  static List<String> forLocale(String languageCode) =>
      languageCode == 'ur' ? const [urdu, arabic, bengali] : const [arabic, bengali, urdu];
}
