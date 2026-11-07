import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'search_text.dart';

/// Hisn al-Muslim (Sa'id bin Ali bin Wahf al-Qahtani), as published in
/// open-hadith-data from sunnah.com: the Arabic, a transliteration, an
/// English translation, and the book's own note of where each dua is found.
class HisnChapter {
  const HisnChapter(this.number, this.en, this.ar);
  final int number;
  final String en;
  final String ar;
}

class HisnDua {
  HisnDua({
    required this.number,
    required this.chapter,
    required this.arabic,
    this.transliteration,
    this.translation,
    this.context,
    this.reference,
    this.url,
  }) : _index = SearchText.normalize('$arabic $transliteration $translation $reference');

  final String number;
  final int chapter;
  final String arabic;
  final String? transliteration;
  final String? translation;
  final String? context;

  /// Where the book says the dua is found, e.g. "Al-Bukhari 11/113; Muslim 4/2083".
  final String? reference;
  final String? url;
  final String _index;

  bool matches(List<String> words) => words.every(_index.contains);
}

class HisnBook {
  HisnBook(this.source, this.chapters, this.duas);
  final String source;
  final List<HisnChapter> chapters;
  final List<HisnDua> duas;

  late final Map<int, HisnChapter> _byNumber = {for (final c in chapters) c.number: c};
  late final Map<int, List<HisnDua>> _byChapter = () {
    final m = <int, List<HisnDua>>{};
    for (final d in duas) {
      (m[d.chapter] ??= []).add(d);
    }
    return m;
  }();

  HisnChapter? chapter(int n) => _byNumber[n];
  List<HisnDua> inChapter(int n) => _byChapter[n] ?? const [];

  /// Duas whose text, transliteration, translation or reference contain every
  /// word; chapters whose name does.
  ({List<HisnChapter> chapters, List<HisnDua> duas}) search(String q) {
    final w = SearchText.words(q);
    if (w.isEmpty) return (chapters: const [], duas: const []);
    return (
      chapters: chapters.where((c) => w.every(SearchText.normalize('${c.en} ${c.ar}').contains)).toList(),
      duas: duas.where((d) => d.matches(w)).toList(),
    );
  }

  static HisnBook parse(String json) {
    final j = jsonDecode(json) as Map<String, Object?>;
    return HisnBook(
      j['source']! as String,
      [
        for (final c in j['chapters']! as List<Object?>)
          if (c case {'n': final int n, 'en': final String en, 'ar': final String ar}) HisnChapter(n, en, ar),
      ],
      [
        for (final d in j['duas']! as List<Object?>)
          if (d case final Map<String, Object?> m)
            HisnDua(
              number: m['n']! as String,
              chapter: m['ch']! as int,
              arabic: m['ar']! as String,
              transliteration: m['tr'] as String?,
              translation: m['en'] as String?,
              context: m['ctx'] as String?,
              reference: m['ref'] as String?,
              url: m['url'] as String?,
            ),
      ],
    );
  }
}

final hisnProvider = FutureProvider<HisnBook>(
  (ref) async => HisnBook.parse(await rootBundle.loadString('assets/sources/hisn.json')),
);
