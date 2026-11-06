import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tokens.dart';

/// Until the Moment Engine lands (Phase 2) the palette is a neutral default.
/// The debug panel can override it to preview every moment.
class PaletteOverride extends Notifier<MomentPalette?> {
  @override
  MomentPalette? build() => null;
  void set(MomentPalette? p) => state = p;
}

final paletteOverrideProvider = NotifierProvider<PaletteOverride, MomentPalette?>(PaletteOverride.new);

final activePaletteProvider = Provider<MomentPalette>(
  (ref) => ref.watch(paletteOverrideProvider) ?? MomentPalette.dhuhr,
);

/// `null` follows the device locale.
class LocaleOverride extends Notifier<Locale?> {
  @override
  Locale? build() => null;
  void set(Locale? l) => state = l;
}

final localeOverrideProvider = NotifierProvider<LocaleOverride, Locale?>(LocaleOverride.new);
