import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('first run asks for a location, tabs navigate', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 9, 41)));
    await tester.pumpAndSettle();
    expect(find.text('Where are you praying from?'), findsOneWidget);
    expect(find.text('Use my location'), findsOneWidget);

    await tester.tap(find.byTooltip('Duas'));
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
    await tester.tap(find.text('বিছানা ঝেড়ে নিন, তারপর দোয়া পড়ুন'));
    await tester.pumpAndSettle();
    expect(find.textContaining('HadeethEnc.com'), findsWidgets);
    expect(find.textContaining('বিছানা'), findsWidgets);
  });

  testWidgets('bedtime checklist ticks and resets with the prayer day', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 22, 45), place: dhaka));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Before you sleep'), 200);
    expect(find.text('0 of 4'), findsOneWidget);
    // Folded: three of four show; the circle ticks, the title opens the hadith.
    final tick = find.byIcon(Icons.radio_button_unchecked_rounded).first;
    await tester.ensureVisible(tick);
    await tester.pumpAndSettle();
    await tester.tap(tick);
    await tester.pumpAndSettle();
    expect(find.text('1 of 4'), findsOneWidget);
  });

  testWidgets('another city shows its own clock and says so', (tester) async {
    // 16:00 UTC: 16:00 in London, 22:00 on this Dhaka-time test machine.
    await tester.pumpWidget(await app(at: DateTime.utc(2026, 11, 6, 16), place: london));
    await tester.pumpAndSettle();
    expect(find.text('London time'), findsOneWidget);
    expect(find.text('4:00'), findsOneWidget);
  });
}
