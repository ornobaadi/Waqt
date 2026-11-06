import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/data/content/content_repository.dart';
import 'package:waqt/domain/moments/moment.dart';

import '../../tool/src/content_compiler.dart';

String item({
  String id = 'sample_item',
  String type = 'hadith',
  String collection = 'bukhari',
  String number = '1',
  String url = 'https://sunnah.com/bukhari:1',
  String status = 'draft',
  String extra = '',
  String review = '',
}) =>
    '''
  - id: $id
    kind: dua
    title:
      en: "Sample"
    source:
      type: $type
      collection: $collection
      number: "$number"
      url: $url
$extra
    review:
      status: $status
$review
    version: 1
''';

const fullText = '''
    arabic: "نص"
    translations:
      en:
        text: "Text"
        translator: "Translator"
''';

const fullSource = '''
      narrator: "Narrator"
      grade: sahih
      graded_by: "Grader"
''';

CompileResult compile(String items, {String moments = '', bool release = false}) => compileContent(
  itemFiles: {'t.yaml': 'items:\n$items'},
  momentsYaml: moments,
  contentVersion: 't',
  release: release,
);

List<String> errors(CompileResult r) => r.errors.map((e) => e.message).toList();

/// Inserts lines into the source block of an item.
String withSource(String yaml, String lines) => yaml.replaceFirst('      url:', '${lines.trimRight()}\n      url:');

void main() {
  test('a minimal draft is valid', () {
    final r = compile(item(), moments: 'lastThird:\n  - sample_item\n');
    expect(r.ok, isTrue, reason: '${r.errors}');
    expect((r.bundle['moments']! as Map)['lastThird'], ['sample_item']);
  });

  test('weak grades are rejected, not labelled', () {
    final r = compile(withSource(item(), '      grade: daif'));
    expect(errors(r).single, contains('weak narrations are excluded'));
  });

  test('checked needs text, translator, narrator, grade and who checked', () {
    final r = compile(item(status: 'checked'));
    final e = errors(r).join('\n');
    for (final need in ['arabic', 'translator', 'narrator', 'graded_by', 'checked_by', 'checked_on']) {
      expect(e, contains(need));
    }
  });

  test('approved needs the scholar', () {
    final ok = withSource(
      item(status: 'approved', extra: fullText, review: '      checked_by: A\n      checked_on: 2026-11-06\n'),
      fullSource,
    );
    expect(errors(compile(ok)).join(), contains('approved_by'));
    final signed = ok.replaceFirst(
      'checked_on: 2026-11-06',
      'checked_on: 2026-11-06\n      approved_by: Sh. B\n      approved_on: 2026-11-07',
    );
    expect(compile(signed).ok, isTrue, reason: '${compile(signed).errors}');
  });

  test('sources must be traceable', () {
    expect(errors(compile(item(url: 'https://example.com/x'))).single, contains('host'));
    expect(errors(compile(item(collection: 'unknown'))).single, contains('not a known collection'));
    expect(
      errors(compile(item(type: 'quran', collection: 'quran', number: '18', url: 'https://quran.com/18'))).single,
      contains('18:1'),
    );
    expect(
      compile(item(type: 'quran', collection: 'quran', number: '18:1-10', url: 'https://quran.com/18/1-10')).ok,
      isTrue,
    );
  });

  test('moments must exist and link known items', () {
    expect(errors(compile(item(), moments: 'midnightSnack:\n  - sample_item\n')).single, contains('unknown moment'));
    expect(errors(compile(item(), moments: 'bedtime:\n  - nope\n')).single, contains('unknown item'));
  });

  test('duplicate ids are rejected', () {
    expect(errors(compile(item() + item())).single, 'duplicate id');
  });

  test('release builds keep only approved items and their links', () {
    final r = compile(item(), moments: 'bedtime:\n  - sample_item\n', release: true);
    expect(r.ok, isTrue);
    expect(r.bundle['items'], isEmpty);
    expect(r.bundle['moments'], isEmpty);
  });

  group('repository', () {
    final json = compile(
      item(id: 'a') + item(id: 'b'),
      moments: 'bedtime:\n  - a\n  - b\n',
    ).json;

    test('dev shows drafts in order', () {
      final b = ContentBundle.parse(json, includeUnreviewed: true);
      expect(b.forMoment(MomentId.bedtime).map((i) => i.id), ['a', 'b']);
      expect(b.forMoment(MomentId.lastThird), isEmpty);
    });

    test('release never shows unreviewed items, even if bundled', () {
      final b = ContentBundle.parse(json, includeUnreviewed: false);
      expect(b.length, 0);
      expect(b.forMoment(MomentId.bedtime), isEmpty);
    });
  });

  group('repository content', () {
    final files = {
      for (final f in Directory('content/items').listSync().whereType<File>().where((f) => f.path.endsWith('.yaml')))
        f.uri.pathSegments.last: f.readAsStringSync(),
    };
    final r = compileContent(
      itemFiles: files,
      momentsYaml: File('content/moments.yaml').readAsStringSync(),
      contentVersion: File('content/VERSION').readAsStringSync().trim(),
    );

    test('validates', () => expect(r.ok, isTrue, reason: r.errors.join('\n')));

    test('shipped bundle is up to date (run: dart run tool/content.dart build)', () {
      final shipped = File('assets/content/content.json').readAsStringSync().trim();
      final releaseShipped = shipped.contains('"release": true');
      final expected = releaseShipped
          ? compileContent(
              itemFiles: files,
              momentsYaml: File('content/moments.yaml').readAsStringSync(),
              contentVersion: File('content/VERSION').readAsStringSync().trim(),
              release: true,
            ).json
          : r.json;
      expect(shipped, expected.trim());
    });
  });
}
