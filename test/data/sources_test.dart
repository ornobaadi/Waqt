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
      // The text stays Arabic; only book and grade are named in Bangla, in HadeethEnc's own words.
      expect(eid.meta('bn')!.text, eid.arabic!.text);
      expect(eid.meta('bn')!.grade, isNot(eid.arabic!.grade));
      expect(eid.meta('bn')!.grade, bundle[5503]!.translation('bn')!.grade);
    });

    test('no weak hadith', () {
      final raw = jsonDecode(File('assets/sources/hadeethenc.json').readAsStringSync()) as Map;
      for (final e in (raw['items'] as Map).values.cast<Map<String, Object?>>()) {
        expect('${(e['ar']! as Map)['grade']}', isNot(contains('ضعيف')));
      }
    });
  });

  group('per madhab', () {
    final json = File('assets/sources/days.json').readAsStringSync();
    String titles(String madhab, MomentId m) =>
        DayGuides.parse(json, madhab: madhab).forMoment(m).map((i) => i.title('en')).join(' | ');

    test('Witr: wajib for a Hanafi, a stressed Sunnah for the other schools, same hadith', () {
      for (final m in [MomentId.lastThird, MomentId.bedtime]) {
        expect(titles('hanafi', m), contains('it is wajib'));
        expect(titles('hanafi', m), isNot(contains('stressed Sunnah')));
        for (final other in ['shafii', 'maliki', 'hanbali']) {
          expect(titles(other, m), contains('stressed Sunnah'), reason: other);
          expect(titles(other, m), isNot(contains('wajib')), reason: other);
        }
      }
      final g = DayGuides.parse(json, madhab: 'hanafi');
      expect(g.forMoment(MomentId.lastThird).where((i) => i.title('en').contains('Witr')).single.he, 11262);
    });

    test('everything else is the same for all four schools', () {
      for (final m in MomentId.values) {
        final counts = {
          for (final x in ['hanafi', 'shafii', 'maliki', 'hanbali']) titles(x, m).split(' | ').length,
        };
        expect(counts, hasLength(1), reason: m.name);
      }
    });

    test("new sourced items: Sha'ban, Umrah in Ramadan, the sacrifice, Friday, after salah", () {
      final g = DayGuides.parse(json, madhab: 'hanafi');
      expect(g.forOccasion(OccasionId.shaban).map((i) => i.he), [6213, 4508]);
      expect(g.forOccasion(OccasionId.ramadan).map((i) => i.he), contains(2753));
      expect(g.forOccasion(OccasionId.eidAlAdha).map((i) => i.he), contains(2971));
      expect(g.forOccasion(OccasionId.jumuah).map((i) => i.he), containsAll([3107, 4449]));
      expect(g.forMoment(MomentId.afterSalah).map((i) => i.he), containsAll([10950, 3518]));
      expect(g.forMoment(MomentId.betweenAdhanIqamah).map((i) => i.he), contains(11251));
    });
  });

  group('duas by task', () {
    final bundle = HeBundle.parse(File('assets/sources/hadeethenc.json').readAsStringSync());
    final book = DuaBook.parse(File('assets/sources/duas.json').readAsStringSync());
    String flat(String s) => s.replaceAll(RegExp('[‎‏­﻿]'), '').split(RegExp(r'\s+')).join(' ');

    test('every task has duas, every label is in every language', () {
      expect(book.tasks, hasLength(9));
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
