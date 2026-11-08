@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waqt/domain/hijri/hijri_service.dart';
import 'package:waqt/platform/sensors/heading.dart';

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
    'duas search',
    (t) async => shoot(
      t,
      '16c_duas_search',
      await app(at: DateTime(2026, 11, 6, 9, 41), place: dhaka),
      then: () async {
        await t.tap(find.text('Duas'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField), 'travel');
      },
    ),
  );

  testWidgets(
    'reading size',
    (t) async => shoot(
      t,
      '41b_reading_size',
      await app(at: DateTime(2026, 11, 6, 9, 41), place: dhaka),
      then: () async {
        await t.tap(find.text('Settings'));
        await t.pumpAndSettle();
        await t.scrollUntilVisible(find.text('Saudi High Judiciary Council'), 200);
        await t.pumpAndSettle();
        await t.tap(find.text('Reading size'));
      },
    ),
  );

  testWidgets(
    'hadith download',
    (t) async => shoot(
      t,
      '16d_hadith_download',
      await app(at: DateTime(2026, 11, 6, 9, 41), place: dhaka),
      then: () async {
        await t.tap(find.text('Duas'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField), 'patience');
      },
    ),
  );

  testWidgets(
    'sheet',
    (t) async => shoot(
      t,
      '17_dua_sheet',
      await app(at: DateTime(2026, 11, 6, 22, 45), place: dhaka),
      then: () async {
        // The bedtime checklist, sourced; a tap on a title offers the library.
        await t.scrollUntilVisible(find.text('Before you sleep'), 200);
        await t.runAsync(() async {
          await t.tap(find.text('Wudu, and lie on your right side'));
          await Future<void>.delayed(const Duration(milliseconds: 500));
        });
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
        await t.tap(find.text("Arafah, Ashura, Jumu'ah, Ramadan and more"));
      },
    ),
  );

  DateTime civilOf(int y, int m, int d) {
    var g = DateTime(2026, 11, 1, 12);
    while (const HijriService().dateFor(g) != HijriDate(y, m, d)) {
      g = g.add(const Duration(days: 1));
    }
    return g;
  }

  testWidgets('ramadan taraweeh', (t) async {
    final d = civilOf(1448, 9, 10);
    await shoot(t, '64_now_taraweeh', await app(at: DateTime(d.year, d.month, d.day, 20, 45), place: dhaka));
  });

  testWidgets('ramadan afternoon', (t) async {
    final d = civilOf(1448, 9, 10);
    await shoot(t, '65_now_ramadan_asr', await app(at: DateTime(d.year, d.month, d.day, 17, 30), place: dhaka));
  });

  testWidgets(
    'adjust times',
    (t) async => shoot(
      t,
      '66_adjust_times',
      await app(at: DateTime(2026, 11, 6, 9, 41), place: dhaka),
      then: () async {
        await t.tap(find.text('Settings'));
        await t.pumpAndSettle();
        await t.tap(find.text('Adjust times'));
      },
    ),
  );

  testWidgets('eid al-fitr', (t) async {
    final d = civilOf(1448, 10, 1);
    await shoot(t, '60_now_eid_fitr', await app(at: DateTime(d.year, d.month, d.day, 6, 40), place: dhaka));
  });

  testWidgets('arafah fast', (t) async {
    final d = civilOf(1448, 12, 9);
    await shoot(t, '61_now_arafah', await app(at: DateTime(d.year, d.month, d.day, 10, 0), place: dhaka));
  });

  testWidgets('moon sighting', (t) async {
    final d = civilOf(1448, 9, 29);
    await shoot(t, '62_now_sighting', await app(at: DateTime(d.year, d.month, d.day, 19, 30), place: dhaka));
  });

  testWidgets(
    'calendar',
    (t) async => shoot(
      t,
      '63_calendar',
      await app(at: DateTime(2026, 11, 6, 9, 41), place: dhaka),
      then: () async => t.tap(find.byIcon(Icons.calendar_month_outlined)),
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

  Future<void> openCounter(WidgetTester t) async {
    await t.tap(find.text('Duas'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Open counter'));
    await t.pumpAndSettle();
  }

  testWidgets(
    'counter picker',
    (t) async => shoot(
      t,
      '22b_counter_picker',
      await app(at: DateTime(2026, 11, 6, 12, 38), place: dhaka),
      then: () async {
        await openCounter(t);
        await t.tap(find.byIcon(Icons.expand_more_rounded));
      },
    ),
  );

  testWidgets(
    'counter today',
    (t) async => shoot(
      t,
      '22c_counter_today',
      await app(at: DateTime(2026, 11, 6, 12, 38), place: dhaka),
      then: () async {
        await openCounter(t);
        for (var i = 0; i < 40; i++) {
          await t.tapAt(const Offset(195, 400));
          await t.pump(const Duration(milliseconds: 30));
        }
        await t.pumpAndSettle();
        await t.tap(find.byIcon(Icons.today_rounded));
      },
    ),
  );

  testWidgets('hadith in bangla', (t) async {
    // HadeethEnc's Bangla, bundled: opens before the library is downloaded.
    final d = civilOf(1448, 10, 1);
    await shoot(
      t,
      '60c_hadith_bn',
      await app(at: DateTime(d.year, d.month, d.day, 15, 0), place: dhaka, locale: const Locale('bn')),
      then: () async {
        await t.runAsync(() async {
          await t.tap(find.text('আজ রোজা রাখবেন না'));
          await Future<void>.delayed(const Duration(milliseconds: 500));
        });
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets(
    'night stack in bangla',
    (t) async => shoot(
      t,
      '66_now_night_stack_bn',
      await app(at: DateTime(2026, 11, 7, 21, 30), place: dhaka, locale: const Locale('bn')),
      then: () async => t.drag(find.byType(Scrollable).first, const Offset(0, -700)),
    ),
  );

  testWidgets('eid hadith not yet translated', (t) async {
    // HadeethEnc has the Eid dates hadith in Arabic only, so far: Arabic and a note.
    final d = civilOf(1448, 10, 1);
    await shoot(
      t,
      '60d_hadith_arabic_only_bn',
      await app(at: DateTime(d.year, d.month, d.day, 6, 40), place: dhaka, locale: const Locale('bn')),
      then: () async {
        await t.scrollUntilVisible(find.text('নামাজের আগে বেজোড় সংখ্যক খেজুর খান'), 200);
        await t.drag(find.byType(Scrollable).first, const Offset(0, -300));
        await t.pumpAndSettle();
        await t.runAsync(() async {
          await t.tap(find.text('নামাজের আগে বেজোড় সংখ্যক খেজুর খান'));
          await Future<void>.delayed(const Duration(milliseconds: 500));
        });
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('eid al-fitr afternoon', (t) async {
    final d = civilOf(1448, 10, 1);
    await shoot(t, '60b_now_eid_afternoon', await app(at: DateTime(d.year, d.month, d.day, 15, 0), place: dhaka));
  });

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

  for (final (name, heading, locale) in [
    ('30_qibla_turn', const Heading(240, 4), null),
    ('31_qibla_aligned', const Heading(277.5, 3), null),
    ('32_qibla_ar', const Heading(330, 5), const Locale('ar')),
    ('33_qibla_tilted', const Heading(200, 60), null),
  ]) {
    testWidgets(
      name,
      (t) async => shoot(
        t,
        name,
        await app(at: DateTime(2026, 11, 6, 9, 41), place: dhaka, heading: heading, locale: locale),
        then: () async {
          await t.tap(find.byIcon(Icons.explore_outlined));
        },
      ),
    );
  }

  for (final (name, at) in [
    ('08b_settings_footer', DateTime(2026, 11, 6, 9, 41)),
    ('08c_settings_footer_night', DateTime(2026, 11, 6, 22, 45)),
  ]) {
    testWidgets(
      name,
      (t) async => shoot(
        t,
        name,
        await app(at: at, place: dhaka),
        then: () async {
          await t.tap(find.text('Settings'));
          await t.pumpAndSettle();
          await t.scrollUntilVisible(find.text('Remember me in your duas.'), 300);
          await t.runAsync(() async {
            final img = t.widget<Image>(find.byType(Image).last);
            await precacheImage(img.image, t.element(find.byType(Image).last));
          });
        },
      ),
    );
  }

  testWidgets(
    'today empty',
    (t) async => shoot(
      t,
      '11b_today_empty',
      await app(at: DateTime(2026, 11, 6, 9, 41)),
      then: () async => t.tap(find.text('Today')),
    ),
  );

  Future<void> openReminders(WidgetTester t) async {
    await t.tap(find.text('Settings'));
    await t.pumpAndSettle();
    await t.tap(find.text("Arafah, Ashura, Jumu'ah, Ramadan and more"));
  }

  testWidgets(
    'reminders off',
    (t) async => shoot(
      t,
      '20b_reminders_off',
      await app(at: DateTime(2026, 11, 6, 12, 38), place: dhaka, stored: {'reminders.enabled.v2': <String>[]}),
      then: () => openReminders(t),
    ),
  );

  testWidgets(
    'reminders before ashura',
    (t) async => shoot(
      t,
      '20c_reminders_ashura',
      await app(at: civilOf(1449, 1, 6).add(const Duration(hours: 13)), place: dhaka),
      then: () => openReminders(t),
    ),
  );

  testWidgets(
    'reminder preview',
    (t) async => shoot(
      t,
      '20d_reminder_preview',
      await app(at: DateTime(2026, 11, 6, 12, 38), place: dhaka),
      then: () async {
        await openReminders(t);
        await t.pumpAndSettle();
        await t.tap(find.byIcon(Icons.visibility_outlined).at(3));
      },
    ),
  );
}
