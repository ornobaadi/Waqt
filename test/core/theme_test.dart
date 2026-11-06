import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/theme/tokens.dart';
import 'package:waqt/core/theme/waqt_theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final p in MomentPalette.values) {
    group(p.name, () {
      final t = WaqtTokens.fromPalette(p);
      test('ink on ground ≥ 4.5:1', () => expect(_contrast(t.ink, t.ground), greaterThanOrEqualTo(4.5)));
      test('muted ink on ground and surface ≥ 4.5:1', () {
        expect(_contrast(Color.alphaBlend(t.inkMuted, t.ground), t.ground), greaterThanOrEqualTo(4.5));
        expect(_contrast(Color.alphaBlend(t.inkMuted, t.surface), t.surface), greaterThanOrEqualTo(4.5));
      });
      test('hero ink on hero surface ≥ 4.5:1', () {
        expect(_contrast(t.heroInk, t.heroSurface), greaterThanOrEqualTo(4.5));
        final body = Color.alphaBlend(t.heroInk.withValues(alpha: 0.72), t.heroSurface);
        expect(_contrast(body, t.heroSurface), greaterThanOrEqualTo(4.5));
      });
    });
  }

  test('dark palettes are the night-side moments', () {
    expect(MomentPalette.values.where((p) => p.isDark).toSet(), {
      MomentPalette.maghrib,
      MomentPalette.night,
      MomentPalette.bedtime,
    });
  });
}
