import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/diagnostics/reports.dart';
import 'package:waqt/data/content/content_repository.dart';
import 'package:waqt/l10n/app_localizations.dart';

import '../helpers/harness.dart';

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('${locale.languageCode}: Now and Settings render without errors', (t) async {
      await t.pumpWidget(await app(at: DateTime(2026, 11, 6, 16, 20), place: dhaka, locale: locale));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final dir = Directionality.of(t.element(find.byType(Scaffold).first));
      expect(dir, ['ar', 'ur'].contains(locale.languageCode) ? TextDirection.rtl : TextDirection.ltr);
      await t.tap(find.byIcon(Icons.tune_outlined));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  }

  test('content reports carry the reference, never the location', () {
    final bundle = ContentBundle.parse(File('assets/content/content.json').readAsStringSync(), includeUnreviewed: true);
    final item = bundle.items.first;
    final uri = Reports.contentIssue(item);
    expect(uri.scheme, 'mailto');
    expect(uri.path, Reports.email);
    expect(uri.query, isNot(contains('+')));
    final body = Uri.decodeComponent(uri.query.split('&body=').last);
    expect(body, contains(item.id));
    expect(body, contains(item.source.number));
    expect(body.toLowerCase(), isNot(contains('dhaka')));
    expect(body, isNot(contains('23.8')));
  });
}
