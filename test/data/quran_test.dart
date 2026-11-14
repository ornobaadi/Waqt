import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/data/quran/quran.dart';
import 'package:waqt/data/quran/quran_prefs.dart';
import 'package:waqt/data/quran/quran_translation.dart';
import 'package:waqt/data/quran/recitation.dart';
import 'package:flutter/material.dart';
import 'package:waqt/features/quran/quran_screen.dart' show findSurahs;
import 'package:waqt/features/quran/reader_screen.dart' show translationSpans;

void main() {
  final raw = File('assets/quran/quran-uthmani.txt').readAsStringSync();
  final q = Quran.parse(raw, File('assets/quran/meta.json').readAsStringSync());

  test('the whole Quran: 114 surahs, 6236 ayat, Tanzil text with its notice kept', () {
    expect(q.surahs, hasLength(114));
    expect(q.surahs.fold<int>(0, (n, s) => n + s.ayahs), 6236);
    expect(raw, contains('Tanzil Quran Text (Uthmani'));
    expect(raw, contains('CHANGING IT IS NOT ALLOWED'));
    expect(q.surah(2).ayahs, 286);
    expect(q.surah(114).arabic, 'الناس');
    expect(q.ayah(114, 6), startsWith('مِنَ'));
  });

  test('basmala: its own heading, not repeated in ayah 1; none for at-Tawbah; al-Fatihah keeps it', () {
    expect(q.basmalaOf(1), isNull);
    expect(q.basmalaOf(9), isNull);
    expect(q.display(1, 1), q.ayah(1, 1));
    expect(q.basmalaOf(2), q.ayah(1, 1));
    expect(q.display(2, 1), 'الٓمٓ');
    // At-Tin and al-Qadr write it with a shadda on the ba: kept as written.
    for (final s in [95, 97]) {
      expect(q.basmalaOf(s), isNot(q.ayah(1, 1)));
      expect('${q.basmalaOf(s)} ${q.display(s, 1)}', q.ayah(s, 1));
    }
    for (var s = 2; s <= 114; s++) {
      if (s == 9) continue;
      expect('${q.basmalaOf(s)} ${q.display(s, 1)}'.trim(), q.ayah(s, 1), reason: 'surah $s');
    }
  });

  test('IndoPak: every ayah, its own marks, al-Fatihah numbered as Hafs, the basmala as a heading', () {
    final ip = q.inIndoPak(IndoPakText.parse(File('assets/quran/quran-indopak.json').readAsStringSync()));
    expect(ip.indoPak!.ayat.map((s) => s.length).toList(), [for (final s in q.surahs) s.ayahs]);
    expect(ip.marksInText, isTrue);
    // Al-Fatihah: ayah 1 is the basmala, al-hamdu is 2, and 7 ends at ad-dallin.
    expect(ip.display(1, 1), startsWith('بِسْمِ'));
    expect(ip.display(1, 2), startsWith('اَلْحَمْدُ'));
    expect(ip.display(1, 7), endsWith('۝٧ࣖ'));
    expect(ip.basmalaOf(1), isNull);
    expect(ip.basmalaOf(9), isNull);
    expect(ip.basmalaOf(2), ip.indoPak!.heading);
    expect(ip.indoPak!.basmala, endsWith('۝'));
    expect(ip.display(1, 1), ip.indoPak!.heading);
    expect(ip.display(2, 1), isNot(contains('بِسْمِ')));
    expect(ip.display(2, 286), contains('۝٢٨٦'));
    // Numbering, juz and pages are shared with the Uthmani text.
    expect(ip.juzOf(2, 142), 2);
    expect(q.marked(2, 2), endsWith('۝٢'));
  });

  test('juz and pages', () {
    expect(q.juzOf(1, 1), 1);
    expect(q.juzOf(2, 141), 1);
    expect(q.juzOf(2, 142), 2);
    expect(q.juzOf(18, 75), 16);
    expect(q.juzOf(114, 6), 30);
    expect(q.pageOf(1, 1), 1);
    expect(q.pageOf(2, 1), 2);
    expect(q.pageOf(114, 6), 604);
    expect(arabicDigits(286), '٢٨٦');
  });

  test('recitation: basmala first where there is one, EveryAyah file names', () {
    expect(recitedAyahs(q, 1).first, 1);
    expect(recitedAyahs(q, 9).first, 1);
    expect(recitedAyahs(q, 2), [0, for (var a = 1; a <= 286; a++) a]);
    expect(reciterById('husary').url(2, 255).toString(), 'https://everyayah.com/data/Husary_64kbps/002255.mp3');
    expect(reciterById('nobody').id, 'alafasy');
    final store = RecitationStore(Directory('x'));
    expect(store.file(reciters.first, 2, 0).path, endsWith('002/001001.mp3'));
  });

  test('a translation for every app language but Arabic', () {
    expect(quranTranslations.keys.toSet(), {'en', 'ur', 'bn', 'id', 'tr', 'fr'});
    expect(quranTranslations['bn']!.file.toString(), 'https://quranenc.com/downloads/sqlite/bengali_zakaria.zip');
  });

  test('reading settings survive a round trip', () {
    const p = QuranPrefs(
      arabicScale: 1.4,
      translation: false,
      reciter: 'ghamdi',
      mobileData: true,
      speed: 1.25,
      indoPak: true,
      hintSeen: true,
    );
    final back = QuranPrefs.fromJson(p.toJson());
    expect(
      (back.arabicScale, back.translation, back.reciter, back.mobileData, back.speed, back.indoPak, back.hintSeen),
      (1.4, false, 'ghamdi', true, 1.25, true, true),
    );
  });

  test('find a surah by number, common spelling, English or Arabic name', () {
    List<int> f(String query) => findSurahs(q, query).map((s) => s.n).toList();
    expect(f('36'), [36]);
    expect(f('٣٦'), [36]);
    expect(f('2:255'), [2]);
    expect(f('999'), isEmpty);
    expect(f('yasin'), contains(36));
    expect(f('Ya-Sin'), contains(36));
    expect(f('kahf'), [18]);
    expect(f('Al-Fatihah'), [1]);
    expect(f('baqarah'), [2]);
    expect(f('mulk'), [67]);
    expect(f('The Cow'), [2]);
    expect(f('الكهف'), [18]);
    expect(f('كهف'), [18]);
    expect(f('zzzz'), isEmpty);
    expect(f('al'), containsAll([1, 2, 18, 67]));
    expect(f('al-kahf'), [18]);
    expect(f(''), hasLength(114));
  });

  test('surah names in each language', () {
    expect(q.surah(2).nameIn('bn'), 'আল-বাকারা');
    expect(q.surah(2).nameIn('tr'), 'Bakara');
    expect(q.surah(2).nameIn('ar'), 'البقرة');
    expect(q.surah(1).nameIn('en'), 'Al-Fatihah');
    expect(q.surah(1).meaningIn('fr'), "L'ouverture");
    expect(q.surah(36).meaningIn('bn'), isEmpty); // the meaning would only repeat the name
    for (final lang in ['en', 'ar', 'ur', 'bn', 'id', 'tr', 'fr']) {
      expect(q.surahs.every((s) => s.nameIn(lang).isNotEmpty), isTrue, reason: lang);
    }
    expect(findSurahs(q, 'বাকারা').map((s) => s.n), [2]);
    expect(findSurahs(q, 'Bakara').map((s) => s.n), contains(2));
  });

  test('translations read through: their own number off, footnote marks small', () {
    String plain(String t) => translationSpans(t, Colors.grey).whereType<TextSpan>().map((s) => s.text).join();
    int marks(String t) => translationSpans(t, Colors.grey).whereType<WidgetSpan>().length;
    expect(plain('(1) In the name of Allāh,[2] the Entirely Merciful'), 'In the name of Allāh, the Entirely Merciful');
    expect(marks('(1) In the name of Allāh,[2] the Entirely Merciful'), 1);
    expect(plain('সকল ‘হাম্দ’ [১] আল্লাহ্র [২] , যিনি'), 'সকল ‘হাম্দ’ আল্লাহ্র, যিনি');
    expect(marks('সকল ‘হাম্দ’ [১] আল্লাহ্র [২] , যিনি'), 2);
    // Words in brackets that are part of the translation stay.
    expect(plain('[All] praise is [due] to Allah'), '[All] praise is [due] to Allah');
    // A mark opens the notes when asked to.
    var opened = 0;
    final marks0 = translationSpans('a[1] b', Colors.grey, onMark: () => opened++).whereType<WidgetSpan>();
    (marks0.single.child as GestureDetector).onTap!();
    expect(opened, 1);
    expect(translationSpans('a[1] b', Colors.grey).whereType<WidgetSpan>().single.child, isNot(isA<GestureDetector>()));
  });

  test('transliteration: every ayah, plain to read, credited', () {
    final raw = File('assets/quran/quran-translit.txt').readAsStringSync();
    final tl = Transliteration.parse(raw);
    for (final s in q.surahs) {
      for (var a = 1; a <= s.ayahs; a++) {
        expect(tl.of(s.n, a), isNotEmpty, reason: '${s.n}:$a');
      }
    }
    expect(tl.of(1, 1), 'Bismi Allahi arrahmani arraheem');
    expect(tl.of(112, 1), 'Qul huwa Allahu ahad');
    expect(raw, contains('Tanzil.net'));
    final ayat = const LineSplitter().convert(raw).where((l) => l.isNotEmpty && !l.startsWith('#')).join(' ');
    expect(ayat, isNot(matches(RegExp('<[a-zA-Z/]'))));
    expect(ayat, isNot(contains('AA')));
  });
}
