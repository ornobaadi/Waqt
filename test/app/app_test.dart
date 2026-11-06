import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/app/app.dart';
import 'package:waqt/app/app_state.dart';

void main() {
  testWidgets('shell renders and navigates', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WaqtApp()));
    await tester.pump();
    expect(find.text('Waqt'), findsWidgets);
    expect(find.text('Fajr'), findsOneWidget);

    await tester.tap(find.text('Duas'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Only verified sources'), findsOneWidget);
  });

  testWidgets('Arabic locale lays out right-to-left', (tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: [localeOverrideProvider.overrideWith(() => _Ar())], child: const WaqtApp()),
    );
    await tester.pump();
    expect(find.text('الفجر'), findsOneWidget);
    final dir = Directionality.of(tester.element(find.text('الفجر')));
    expect(dir, TextDirection.rtl);
  });
}

class _Ar extends LocaleOverride {
  @override
  Locale? build() => const Locale('ar');
}
