import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waqt/data/sources/days.dart';
import 'package:waqt/data/sources/duas.dart';
import 'package:waqt/data/sources/hadeethenc.dart';
import 'package:waqt/data/sources/he_library.dart';
import 'package:waqt/data/sources/search_text.dart';
import 'package:waqt/domain/moments/moment.dart';
import 'package:waqt/domain/occasions/occasions.dart';
import 'package:waqt/features/counter/dhikr_data.dart';

const langs = ['en', 'ar', 'ur', 'bn', 'id', 'tr', 'fr'];

void main() {
  group('search text', () {
    test('Arabic: diacritics, tatweel and letter forms do not matter', () {
      expect(SearchText.normalize('الحَمْـدُ لِلّهِ'), SearchText.normalize('الحمد لله'));
      expect(SearchText.normalize('إِنَّمَا الْأَعْمَالُ'), 'انما الاعمال');
      expect(SearchText.normalize('رحمة'), SearchText.normalize('رحمه'));
    });
    test('English: case and punctuation do not matter', () {
      expect(SearchText.words('  Sleep,  "Right" side! '), ['sleep', 'right', 'side']);
    });
  });

  group('HadeethEnc bundle', () {
    final bundle = HeBundle.parse(File('assets/sources/hadeethenc.json').readAsStringSync());
    final guides = DayGuides.parse(File('assets/sources/days.json').readAsStringSync());
    final items = [
      for (final o in OccasionId.values) ...guides.forOccasion(o),
      for (final m in MomentId.values) ...guides.forMoment(m),
    ];

    test('every checklist item: a bundled hadith with its Arabic, a label in every language', () {
      expect(items, isNotEmpty);
      for (final i in items) {
        // Not on HadeethEnc: carries its own reference in every language.
        if (i.referenced case final r?) {
          for (final l in langs) {
            expect(r.referenceIn(l), isNotEmpty, reason: '${i.key} $l');
            expect(r.meaningIn(l), isNotEmpty, reason: '${i.key} $l');
            expect(r.reference[l], isNotNull, reason: '${i.key} $l');
          }
          continue;
        }
        final h = bundle[i.he];
        expect(h?.arabic?.text, isNotEmpty, reason: '${i.he}');
        for (final l in langs) {
          expect(i.titles[l], isNotEmpty, reason: '${i.he} $l');
        }
      }
    });

    test('every dhikr: a bundled hadith, its virtue in every language', () {
      for (final d in builtInDhikr) {
        expect(bundle[d.he!]?.arabic?.text, isNotEmpty, reason: d.id);
        for (final l in langs) {
          expect(d.virtue[l], isNotEmpty, reason: '${d.id} $l');
        }
      }
      expect(bundle[afterSalahHe], isNotNull);
    });

    test('translated where HadeethEnc has it; never another language in its place', () {
      final h = bundle[5503]!; // Sayyid al-istighfar
      expect(h.translation('bn')?.text, contains('ইস্তেগফার'));
      expect(h.translation('ar'), isNull);
      final eid = bundle[65481]!; // Eid dates: Arabic only so far
      expect(eid.translation('bn'), isNull);
      expect(eid.meta('bn'), same(eid.arabic));
    });

    test('no weak hadith', () {
      final raw = jsonDecode(File('assets/sources/hadeethenc.json').readAsStringSync()) as Map;
      for (final e in (raw['items'] as Map).values.cast<Map<String, Object?>>()) {
        expect('${(e['ar']! as Map)['grade']}', isNot(contains('ضعيف')));
      }
    });
  });

  group('duas by task', () {
    final bundle = HeBundle.parse(File('assets/sources/hadeethenc.json').readAsStringSync());
    final book = DuaBook.parse(File('assets/sources/duas.json').readAsStringSync());
    String flat(String s) => s.replaceAll(RegExp('[‎‏­﻿]'), '').split(RegExp(r'\s+')).join(' ');

    test('every task has duas, every label is in every language', () {
      expect(book.tasks, hasLength(8));
      for (final t in book.tasks) {
        expect(book.forTask(t.id), isNotEmpty, reason: t.id);
        for (final l in langs) {
          expect(t.titles[l], isNotEmpty, reason: '${t.id} $l');
        }
      }
      for (final d in book.items) {
        for (final l in langs) {
          expect(d.when[l], isNotEmpty, reason: '${d.id} $l');
        }
        expect(d.latin, isNotEmpty, reason: d.id);
      }
    });

    test("the words are HadeethEnc's, cut from the bundled hadith, unchanged", () {
      for (final d in book.items) {
        final h = bundle[d.he];
        expect(h, isNotNull, reason: '${d.id}: hadith ${d.he} bundled');
        expect(
          SearchText.normalize(h!.arabic!.text),
          contains(SearchText.normalize(d.arabic)),
          reason: '${d.id}: Arabic is in the hadith',
        );
        expect(d.meaning.containsKey('ar'), isFalse, reason: d.id);
        for (final MapEntry(key: l, value: m) in d.meaning.entries) {
          expect(flat(h.translation(l)!.text), contains(m), reason: '${d.id} $l: meaning is in the translation');
        }
      }
    });

    test("no meaning in another language: the reader's, or none", () {
      final waking = book.items.firstWhere((d) => d.id == 'waking');
      expect(waking.meaningIn('en'), isNull);
      expect(book.items.firstWhere((d) => d.id == 'farewell').meaningIn('bn'), contains('আল্লাহকে'));
      expect(book.items.first.meaningIn('ar'), isNull);
    });
  });

  group('library', () {
    late HeLibrary lib;

    setUpAll(() async {
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      // HadeethEnc's own layout for a translated language.
      await db.execute('CREATE TABLE categories (id INTEGER PRIMARY KEY, title TEXT, num INTEGER, parent_id INTEGER)');
      await db.execute(
        'CREATE TABLE hadeeths (id INTEGER, title TEXT, hadeeth TEXT, explanation TEXT, hints TEXT, '
        'hadeeth_ar TEXT, grade TEXT, attribution TEXT, tarteeb INTEGER, ar_version INTEGER)',
      );
      await db.execute(
        'CREATE TABLE category_hadeeth (id INTEGER PRIMARY KEY, category_id INTEGER, hadeeth_id INTEGER)',
      );
      await db.insert('categories', {'id': 268, 'title': 'দোয়া ও যিকির', 'num': 1, 'parent_id': 5});
      await db.insert('categories', {'id': 301, 'title': 'সকাল ও সন্ধ্যার যিকির', 'num': 1, 'parent_id': 268});
      await db.insert('hadeeths', {
        'id': 5503,
        'title': 'সাইয়্যেদুল ইস্তেগফার',
        'hadeeth': 'সাইয়্যেদুল ইস্তেগফার হচ্ছে...',
        'hadeeth_ar': 'سَيِّدُ الِاسْتِغْفَارِ أَنْ تَقُولَ',
        'grade': 'সহীহ',
        'attribution': 'সহীহ বুখারী',
        'ar_version': 2,
      });
      await db.insert('category_hadeeth', {'category_id': 301, 'hadeeth_id': 5503});
      lib = await HeLibrary.fromDatabase('bn', db);
    });

    test('search in the translation and in the Arabic, without diacritics', () async {
      expect((await lib.search('ইস্তেগফার')).single.id, 5503);
      expect((await lib.search('سيد الاستغفار')).single.id, 5503);
      expect(await lib.search('nothing'), isEmpty);
    });

    test('topics: a parent holds its children’s hadiths', () async {
      expect(lib.children(268).single.title, 'সকাল ও সন্ধ্যার যিকির');
      final h = (await lib.inTopic(268)).single;
      expect(h.translation('bn')?.text, startsWith('সাইয়্যেদুল'));
      expect(h.arabic?.text, contains('الِاسْتِغْفَارِ'));
    });
  });
}
