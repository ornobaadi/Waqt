import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waqt/data/sources/hadith_db.dart';
import 'package:waqt/data/sources/hisn.dart';
import 'package:waqt/data/sources/search_text.dart';

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

  group('Hisn al-Muslim', () {
    final book = HisnBook.parse(File('assets/sources/hisn.json').readAsStringSync());

    test('all chapters and duas, every dua in a known chapter', () {
      expect(book.chapters.length, 132);
      expect(book.duas.length, 268);
      expect(book.duas.every((d) => book.chapter(d.chapter) != null), isTrue);
      expect(book.duas.every((d) => d.arabic.isNotEmpty), isTrue);
    });

    test('search by Arabic without diacritics, and by English', () {
      expect(book.search('احيانا بعد ما اماتنا').duas.map((d) => d.number), contains('1'));
      expect(book.search('sleeping').chapters.map((c) => c.number), contains(28));
    });
  });

  group('hadith database', () {
    late HadithDb db;

    setUpAll(() async {
      sqfliteFfiInit();
      final dir = Directory.systemTemp.createTempSync('waqt_hadith');
      final file = File('${dir.path}/h.db')
        ..writeAsBytesSync(gzip.decode(File('assets/sources/hadith.db.gz').readAsBytesSync()));
      db = await HadithDb.fromDatabase(await databaseFactoryFfi.openDatabase(file.path));
    });

    test('every collection loaded', () {
      expect(db.collections.map((c) => c.id), containsAll(['bukhari', 'muslim', 'abudawud', 'tirmidhi', 'nasai']));
      expect(db.collections.fold<int>(0, (a, c) => a + c.count), greaterThan(40000));
    });

    test('a reference goes straight to the hadith', () async {
      final r = await db.search('bukhari 1');
      expect(r.single.reference, 'Sahih al-Bukhari 1');
    });

    test('Arabic search ignores diacritics', () async {
      final r = await db.search('انما الاعمال بالنيات');
      expect(r.map((h) => h.collection), contains('bukhari'));
    });

    test('English words, all required, prefix matching', () async {
      final r = await db.search('intention emigrat');
      expect(r, isNotEmpty);
      expect(r.every((h) => h.english.toLowerCase().contains('emigrat')), isTrue);
    });
  });
}
