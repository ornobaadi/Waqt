@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

/// Renders the real app to PNGs: `flutter test --tags screenshots --update-goldens`.
/// Excluded from CI (font rasterisation differs per OS).
void main() {
  setUpAll(loadAppFonts);

  Future<void> shoot(WidgetTester tester, String name, Widget app, {Future<void> Function()? then}) async {
    debugDisableShadows = false; // real soft shadows, as on device
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    if (then != null) {
      await then();
      await tester.pumpAndSettle();
    }
    try {
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
    } finally {
      debugDisableShadows = true;
    }
  }

  testWidgets('first run', (t) async => shoot(t, '01_first_run', await app(at: DateTime(2026, 11, 6, 9, 41))));

  testWidgets('fajr', (t) async => shoot(t, '02_now_fajr', await app(at: DateTime(2026, 11, 6, 5, 12), place: dhaka)));

  testWidgets(
    'dhuhr',
    (t) async => shoot(t, '03_now_dhuhr', await app(at: DateTime(2026, 11, 6, 12, 38), place: dhaka)),
  );

  testWidgets('asr', (t) async => shoot(t, '04_now_asr', await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka)));

  testWidgets(
    'maghrib',
    (t) async => shoot(t, '05_now_maghrib', await app(at: DateTime(2026, 11, 6, 17, 31), place: dhaka)),
  );

  testWidgets(
    'night',
    (t) async => shoot(t, '06_now_night', await app(at: DateTime(2026, 11, 6, 23, 5), place: dhaka)),
  );

  testWidgets(
    'arabic',
    (t) async => shoot(
      t,
      '07_now_arabic_rtl',
      await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka, locale: const Locale('ar')),
    ),
  );

  testWidgets(
    'settings',
    (t) async => shoot(
      t,
      '08_settings',
      await app(at: DateTime(2026, 11, 6, 12, 38), place: dhaka),
      then: () async => t.tap(find.text('Settings')),
    ),
  );

  testWidgets(
    'method sheet',
    (t) async => shoot(
      t,
      '09_method_sheet',
      await app(at: DateTime(2026, 11, 6, 12, 38), place: dhaka),
      then: () async {
        await t.tap(find.text('Settings'));
        await t.pumpAndSettle();
        await t.tap(find.text('Calculation method'));
      },
    ),
  );

  testWidgets(
    'city search',
    (t) async => shoot(
      t,
      '10_city_search',
      await app(at: DateTime(2026, 11, 6, 9, 41)),
      then: () async {
        await t.tap(find.text('Choose a city'));
        await t.pumpAndSettle();
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 800)));
        await t.enterText(find.byType(TextField), 'ist');
        await t.pump();
      },
    ),
  );

  testWidgets(
    'today timeline',
    (t) async => shoot(
      t,
      '11_today_timeline',
      await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka),
      then: () async => t.tap(find.text('Today')),
    ),
  );

  testWidgets(
    'last third',
    (t) async => shoot(t, '12_now_last_third', await app(at: DateTime(2026, 11, 7, 3, 10), place: dhaka)),
  );

  testWidgets(
    'bedtime',
    (t) async => shoot(t, '13_now_bedtime', await app(at: DateTime(2026, 11, 6, 22, 45), place: dhaka)),
  );

  testWidgets(
    'restricted',
    (t) async => shoot(t, '14_now_restricted', await app(at: DateTime(2026, 11, 6, 6, 12), place: dhaka)),
  );

  testWidgets(
    'developer',
    (t) async => shoot(
      t,
      '15_developer',
      await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka),
      then: () async {
        await t.tap(find.text('Settings'));
        await t.pumpAndSettle();
        await t.scrollUntilVisible(find.text('Fake clock and moment palettes'), 200);
        await t.tap(find.text('Fake clock and moment palettes'));
      },
    ),
  );

  testWidgets(
    'library',
    (t) async => shoot(
      t,
      '16_duas_library',
      await app(at: DateTime(2026, 11, 6, 9, 41), place: dhaka),
      then: () async => t.tap(find.text('Duas')),
    ),
  );

  testWidgets(
    'sheet',
    (t) async => shoot(
      t,
      '17_dua_sheet',
      await app(at: DateTime(2026, 11, 6, 22, 45), place: dhaka),
      then: () async {
        await t.tap(find.byTooltip('Source').first);
      },
    ),
  );

  testWidgets(
    'jumuah morning',
    (t) async => shoot(t, '18_now_jumuah_morning', await app(at: DateTime(2026, 11, 6, 9, 41), place: dhaka)),
  );
}
