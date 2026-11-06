import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('first run asks for a location, tabs navigate', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 9, 41)));
    await tester.pumpAndSettle();
    expect(find.text('Where are you praying from?'), findsOneWidget);
    expect(find.text('Use my location'), findsOneWidget);

    await tester.tap(find.text('Duas'));
    await tester.pumpAndSettle();
    expect(find.text('Only verified sources'), findsOneWidget);
  });

  testWidgets('with a place: current waqt, countdown and times', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka));
    await tester.pumpAndSettle();
    expect(find.text('Dhaka'), findsOneWidget);
    expect(find.textContaining('Maghrib in'), findsOneWidget);
    expect(find.textContaining('AH'), findsOneWidget);
  });

  testWidgets('Arabic locale lays out right-to-left', (tester) async {
    await tester.pumpWidget(await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka, locale: const Locale('ar')));
    await tester.pumpAndSettle();
    final dir = Directionality.of(tester.element(find.text('الفجر')));
    expect(dir, TextDirection.rtl);
  });
}
