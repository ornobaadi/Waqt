import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqt/data/user/user_prefs.dart';

import 'package:waqt/features/duas/dua_views.dart';
import 'package:waqt/features/quran/quran_screen.dart';

import '../helpers/harness.dart';

/// Scrolls the dua on screen until [f] is built and visible.
Future<void> scrollPage(WidgetTester tester, Finder f) async {
  final page = find.descendant(of: find.byType(DuaPage), matching: find.byType(Scrollable)).first;
  await tester.scrollUntilVisible(f, 200, scrollable: page);
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  expect(f, findsOneWidget);
}

void main() {
  testWidgets('first run asks for a location, tabs navigate', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 9, 41)));
    await tester.pumpAndSettle();
    expect(find.text('Where are you praying from?'), findsOneWidget);
    expect(find.text('Use my location'), findsOneWidget);

    await tester.tap(find.byTooltip('Duas'));
    await tester.pumpAndSettle();
    expect(find.text('Duas to say'), findsOneWidget);
    await tester.tap(find.text('Hadith'));
    await tester.pumpAndSettle();
    expect(find.text('Search hadith and duas'), findsOneWidget);
  });

  testWidgets('with a place: current waqt, countdown and times', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka));
    await tester.pumpAndSettle();
    expect(find.text('Dhaka'), findsOneWidget);
    expect(find.textContaining('Maghrib in'), findsOneWidget);
    expect(find.textContaining('AH'), findsOneWidget);
  });

  testWidgets('back on another tab returns to Now instead of leaving', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Maghrib in'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.textContaining('Maghrib in'), findsOneWidget);
  });

  testWidgets('Arabic locale lays out right-to-left', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka, locale: const Locale('ar')));
    await tester.pumpAndSettle();
    final dir = Directionality.of(tester.element(find.text('الفجر')));
    expect(dir, TextDirection.rtl);
  });

  testWidgets('Duas: what fits now opens its hadith, in Bangla, before any download', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 22, 45), place: dhaka, locale: const Locale('bn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('দোয়া'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('হাদিস'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('বিছানা ঝেড়ে নিন, তারপর দোয়া পড়ুন'));
    await tester.pumpAndSettle();
    expect(find.textContaining('HadeethEnc.com'), findsWidgets);
    expect(find.textContaining('বিছানা'), findsWidgets);
  });

  testWidgets('Duas by task: the words first, the hadith on request', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 9, 41), place: dhaka));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Duas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sleep and waking'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('In bed, after dusting it off'));
    await tester.pumpAndSettle();
    expect(find.textContaining('وضعت جنبي'), findsOneWidget);
    await scrollPage(tester, find.textContaining('Bismika rabbi'));
    await scrollPage(tester, find.textContaining('I place my side'));
    expect(find.text('2 of 4'), findsOneWidget);
    // Swipe on: waking has no English meaning on HadeethEnc, so a note, not another language.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('When you wake up'), findsOneWidget);
    await scrollPage(tester, find.textContaining("hasn't published these words"));
    await scrollPage(tester, find.text('See the full hadith'));
    await tester.tap(find.text('See the full hadith'));
    await tester.pumpAndSettle();
    // The whole hadith it is cut from, with its narrator.
    expect(find.textContaining('عَنْ حُذَيْفَةَ'), findsOneWidget);
  });

  testWidgets("Duas by task in Bangla: HadeethEnc's own Bangla meaning", (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 9, 41), place: dhaka, locale: const Locale('bn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('দোয়া'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('সফর'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('সফর'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('মুসাফিরকে বিদায় দেওয়ার সময়'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('মুসাফিরকে বিদায় দেওয়ার সময়'));
    await tester.pumpAndSettle();
    await scrollPage(tester, find.textContaining('আল্লাহকে সঁপে দিলাম'));
  });

  testWidgets('Quran: open a surah, save an ayah, find it under Saved', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 9, 41), place: dhaka));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Quran'));
    await tester.pumpAndSettle();
    expect(find.text('START READING'), findsOneWidget);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('The Opening'), findsOneWidget);
    expect(find.text('Translation'), findsOneWidget); // offered, not yet on the phone
    await tester.tap(find.byTooltip('Next ayah'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('ayah-1:2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save ayah'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(QuranScreen), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Al-Faatiha 1:2'), findsOneWidget);

    // Reading shows on Today, and its row opens the reader where you stopped.
    await tester.tap(find.byTooltip('Today'));
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r'^\d+ (ayah|ayat) read today$')), findsOneWidget);
    await tester.tap(find.textContaining('read today'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ayah-1:2')), findsOneWidget);
  });

  testWidgets('Home: after the prayer, "Say the duas" opens the words, one per page', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka));
    await tester.pumpAndSettle();
    final say = find.text('Say the duas · 4');
    await tester.scrollUntilVisible(say, 200);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(say);
    await tester.pumpAndSettle();
    expect(find.text('1 of 4'), findsOneWidget);
    expect(find.text('After wudu'), findsOneWidget);
  });

  testWidgets('bedtime checklist ticks and resets with the prayer day', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 22, 45), place: dhaka));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Before you sleep'), 200);
    // Four practices and Witr (wajib for a Hanafi, the default).
    expect(find.text('0 of 5'), findsOneWidget);
    // Folded: three of five show; the circle ticks, the title opens the hadith.
    final tick = find.byKey(const ValueKey('checklist-tick')).first;
    await tester.ensureVisible(tick);
    await tester.pumpAndSettle();
    await tester.tap(tick);
    await tester.pumpAndSettle();
    expect(find.text('1 of 5'), findsOneWidget);
  });

  testWidgets('another city shows its own clock and says so', (tester) async {
    // 16:00 UTC: 16:00 in London, 22:00 on this Dhaka-time test machine.
    await tester.pumpWidget(await app(at: DateTime.utc(2026, 11, 6, 16), place: london));
    await tester.pumpAndSettle();
    expect(find.text('London time'), findsOneWidget);
    expect(find.text('4:00'), findsOneWidget);
  });

  testWidgets('onboarding: language is saved, a place moves on, reminders finish', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 9, 41), onboarding: true));
    await tester.pumpAndSettle();
    expect(find.text('The right dua for every moment'), findsOneWidget);
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();
    expect(find.text('Dilini seç'), findsOneWidget);
    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();
    expect((await SharedPreferences.getInstance()).getString('locale.v1'), 'tr');

    expect(find.text('Nerede namaz kılıyorsun?'), findsOneWidget);
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(userPrefsProvider.notifier)
        .setPlace(dhaka);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sonra'));
    await tester.pumpAndSettle();
    expect(find.text('Dhaka'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getBool('onboarded.v1'), true);
  });

  testWidgets('a saved language is used on the next launch', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka, stored: {'locale.v1': 'tr'}));
    await tester.pumpAndSettle();
    expect(find.text('Öğle'), findsWidgets);
  });

  testWidgets('after midnight Isha counts down to this morning Fajr, not the next day', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 9, 0, 2), place: dhaka));
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r'^2\dh')), findsNothing);
    expect(find.textContaining(RegExp(r'^4h \d+m left$')), findsOneWidget);
  });
}
