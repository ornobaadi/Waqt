@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waqt/domain/hijri/hijri_service.dart';

import '../helpers/harness.dart';

/// Renders the real app to PNGs: `flutter test --tags screenshots --update-goldens`.
/// Excluded from CI (font rasterisation differs per OS).
void main() {
  setUpAll(loadAppFonts);

  Future<void> shoot(
    WidgetTester tester,
    String name,
    Widget app, {
    Future<void> Function()? then,
    double textScale = 1,
  }) async {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
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
        await t.scrollUntilVisible(find.text('Fake clock, day jumps and the reference checker'), 200);
        await t.tap(find.text('Fake clock, day jumps and the reference checker'));
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

  testWidgets(
    'setup card',
    (t) async =>
        shoot(t, '19_now_reminder_setup', await app(at: DateTime(2026, 11, 6, 12, 38), place: dhaka, setupCard: true)),
  );

  testWidgets(
    'reminders',
    (t) async => shoot(
      t,
      '20_reminders',
      await app(at: DateTime(2026, 11, 6, 12, 38), place: dhaka),
      then: () async {
        await t.tap(find.text('Settings'));
        await t.pumpAndSettle();
        await t.tap(find.text('Adhkar, Jumu'ah and night reminders, as you choose'));
      },
    ),
  );

  testWidgets('ramadan night', (t) async {
    // The evening before the 23rd night of Ramadan 1448.
    var d = DateTime(2027, 2, 1, 12);
    while (const HijriService().dateFor(d) != const HijriDate(1448, 9, 22)) {
      d = d.add(const Duration(days: 1));
    }
    await shoot(t, '21_now_ramadan_qadr', await app(at: DateTime(d.year, d.month, d.day, 21, 30), place: dhaka));
  });

  testWidgets(
    'counter',
    (t) async => shoot(
      t,
      '22_counter',
      await app(at: DateTime(2026, 11, 6, 12, 38), place: dhaka),
      then: () async {
        await t.tap(find.text('Duas'));
        await t.pumpAndSettle();
        await t.tap(find.byTooltip('Open counter'));
        await t.pumpAndSettle();
        for (var i = 0; i < 12; i++) {
          await t.tapAt(const Offset(195, 400));
          await t.pump(const Duration(milliseconds: 30));
        }
      },
    ),
  );

  testWidgets(
    'fajr sky',
    (t) async => shoot(t, '23_now_fajr_sky', await app(at: DateTime(2026, 11, 6, 5, 40), place: dhaka)),
  );

  testWidgets(
    'maghrib sky',
    (t) async => shoot(t, '24_now_maghrib_sky', await app(at: DateTime(2026, 11, 6, 17, 40), place: dhaka)),
  );

  for (final lang in ['ur', 'bn', 'tr', 'id', 'fr']) {
    testWidgets(
      'lang $lang',
      (t) async =>
          shoot(t, '30_now_$lang', await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka, locale: Locale(lang))),
    );
  }

  testWidgets(
    '200% now',
    (t) async => shoot(t, '40_a11y_now_200', await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka), textScale: 2),
  );

  testWidgets(
    '200% settings',
    (t) async => shoot(
      t,
      '41_a11y_settings_200',
      await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka),
      textScale: 2,
      then: () async => t.tap(find.text('Settings')),
    ),
  );

  testWidgets(
    '200% today',
    (t) async => shoot(
      t,
      '42_a11y_today_200',
      await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka),
      textScale: 2,
      then: () async => t.tap(find.text('Today')),
    ),
  );

  testWidgets(
    'other city',
    (t) async => shoot(t, '50_now_london_from_dhaka', await app(at: DateTime.utc(2026, 11, 6, 16), place: london)),
  );
}
