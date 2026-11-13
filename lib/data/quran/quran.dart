import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One surah, from Tanzil's metadata.
class Surah {
  const Surah({
    required this.n,
    required this.ayahs,
    required this.start,
    required this.arabic,
    required this.name,
    required this.english,
    required this.makki,
    this.names = const {},
  });

  /// Per language: (name, meaning). Missing: the Latin name and English meaning.
  final Map<String, (String, String)> names;

  /// "আল-বাকারা", "Bakara", "Al-Baqarah": the name as readers of [lang] know it.
  String nameIn(String lang) => names[lang]?.$1 ?? names['en']?.$1 ?? name;

  /// What the name means in [lang]; empty where the name says it all (Arabic, Turkish).
  String meaningIn(String lang) => names[lang]?.$2 ?? english;

  final int n;
  final int ayahs;

  /// Index of its first ayah in the whole Quran (0-based).
  final int start;

  /// "الفاتحة"
  final String arabic;

  /// Tanzil's transliterated name, "Al-Faatiha".
  final String name;

  /// "The Opening"
  final String english;
  final bool makki;
}

/// An ayah's place: surah and ayah, both from 1.
typedef AyahRef = ({int surah, int ayah});

/// The Quran as Tanzil publishes it (Uthmani, verbatim), with surah, juz and
/// page metadata. Built by tool/build_quran.py.
class Quran {
  Quran(this.surahs, this._ayahs, this.juz, this.pages, [this.indoPak]);

  final List<Surah> surahs;
  final List<String> _ayahs;

  /// When set, the reader shows this IndoPak text instead of the Uthmani one.
  /// Numbering, juz, pages, translation and recitation stay the same.
  final IndoPakText? indoPak;

  /// The same Quran shown in the IndoPak script.
  Quran inIndoPak(IndoPakText ip) => Quran(surahs, _ayahs, juz, pages, ip);

  /// IndoPak text carries its own ayah marks; the Uthmani gets one drawn.
  bool get marksInText => indoPak != null;

  /// The ayah with its end mark, as the reader draws it.
  String marked(int surah, int ayah) =>
      marksInText ? display(surah, ayah) : '${display(surah, ayah)} \u06DD${arabicDigits(ayah)}';

  /// Where each juz (30) and each Madinah mushaf page (604) begins.
  final List<AyahRef> juz;
  final List<AyahRef> pages;

  Surah surah(int n) => surahs[n - 1];

  /// The ayah exactly as Tanzil has it. The first ayah of most surahs carries
  /// the basmala in front; [display] splits it off for the reader.
  String ayah(int surah, int ayah) => _ayahs[surahs[surah - 1].start + ayah - 1];

  /// A surah's basmala as Tanzil writes it there (the first four words of its
  /// first ayah; in at-Tin and al-Qadr with a shadda on the ba), or null.
  String? basmalaOf(int surah) {
    if (!hasBasmalaHeading(surah)) return null;
    if (indoPak case final ip?) return ip.heading;
    return ayah(surah, 1).split(' ').take(4).join(' ');
  }

  /// The text to show under a surah's basmala heading: the basmala is drawn
  /// once above, so it is not repeated in ayah 1. Al-Fatihah keeps it as its
  /// first ayah; at-Tawbah has none.
  String display(int surah, int ayah) {
    if (indoPak case final ip?) return surah == 1 && ayah == 1 ? ip.heading : ip.ayat[surah - 1][ayah - 1];
    final t = this.ayah(surah, ayah);
    if (ayah != 1 || !hasBasmalaHeading(surah)) return t;
    return t.split(' ').skip(4).join(' ');
  }

  /// Whether the reader draws a basmala above the surah.
  bool hasBasmalaHeading(int surah) => surah != 1 && surah != 9;

  int _index(int surah, int ayah) => surahs[surah - 1].start + ayah - 1;

  /// The juz (1–30) an ayah is in.
  int juzOf(int surah, int ayah) => _last(juz, _index(surah, ayah)) + 1;

  /// The mushaf page (1–604) an ayah is on.
  int pageOf(int surah, int ayah) => _last(pages, _index(surah, ayah)) + 1;

  int _last(List<AyahRef> marks, int i) {
    var lo = 0, hi = marks.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (_index(marks[mid].surah, marks[mid].ayah) <= i) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }

  static Quran parse(String text, String meta) {
    final m = jsonDecode(meta) as Map<String, Object?>;
    final ayahs = [
      for (final line in const LineSplitter().convert(text))
        if (line.isNotEmpty && !line.startsWith('#')) line.split('|').skip(2).join('|'),
    ];
    List<AyahRef> refs(Object? v) => [
      for (final r in v! as List<Object?>)
        if (r case [final int s, final int a]) (surah: s, ayah: a),
    ];
    final names = (m['names'] as Map<String, Object?>?) ?? const {};
    (String, String)? named(String lang, int i) => switch ((names[lang] as List<Object?>?)?[i]) {
      [final String n, final String meaning] => (n, meaning),
      _ => null,
    };
    return Quran(
      [
        for (final (i, s) in (m['suras']! as List<Object?>).indexed)
          if (s case final Map<String, Object?> j)
            Surah(
              names: {for (final lang in names.keys) lang: ?named(lang, i)},
              n: j['n']! as int,
              ayahs: j['ayas']! as int,
              start: j['start']! as int,
              arabic: '${j['ar']}',
              name: '${j['tname']}',
              english: '${j['en']}',
              makki: j['type'] == 'makki',
            ),
      ],
      ayahs,
      refs(m['juz']),
      refs(m['pages']),
    );
  }
}

/// DigitalKhatt's IndoPak text (MIT), one string per ayah with its own mark
/// and pause signs, numbered as Hafs. Built by tool/build_quran.py.
class IndoPakText {
  const IndoPakText(this.basmala, this.ayat);
  final String basmala;
  final List<List<String>> ayat;

  /// The basmala as shown: the mushaf closes it with a bare ۝ (no number),
  /// which the font has no glyph for, so the reader leaves that mark off.
  String get heading => basmala.replaceFirst(RegExp(r'\s*۝$'), '');

  static IndoPakText parse(String json) {
    final j = jsonDecode(json) as Map<String, Object?>;
    return IndoPakText('${j['basmala']}', [
      for (final s in j['ayat']! as List<Object?>) [for (final a in s! as List<Object?>) '$a'],
    ]);
  }
}

final indoPakProvider = FutureProvider<IndoPakText>(
  (ref) async => IndoPakText.parse(await rootBundle.loadString('assets/quran/quran-indopak.json')),
);

final quranProvider = FutureProvider<Quran>((ref) async {
  final text = await rootBundle.loadString('assets/quran/quran-uthmani.txt');
  final meta = await rootBundle.loadString('assets/quran/meta.json');
  return Quran.parse(text, meta);
});

/// Western digits to Arabic-Indic, for ayah markers: 12 → ١٢.
String arabicDigits(int n) => '$n'.split('').map((d) => String.fromCharCode(0x0660 + int.parse(d))).join();
