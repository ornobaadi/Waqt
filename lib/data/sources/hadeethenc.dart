import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One hadith in one language, exactly as HadeethEnc.com publishes it.
class HeText {
  const HeText({required this.text, this.title, this.attribution, this.grade, this.explanation, this.version});
  final String text;
  final String? title, attribution, grade, explanation;
  final int? version;

  static HeText fromJson(Map<String, Object?> m) => HeText(
    text: '${m['text'] ?? ''}',
    title: m['title'] as String?,
    attribution: m['attribution'] as String?,
    grade: m['grade'] as String?,
    explanation: m['explanation'] as String?,
    version: m['version'] as int?,
  );
}

/// A HadeethEnc hadith in the languages we have it in. Arabic is always
/// there; a translation is there once HadeethEnc has published it.
class HeHadith {
  const HeHadith(this.id, this.byLang, [this.sources = const {}]);
  final int id;
  final Map<String, HeText> byLang;

  /// Book and grade in a language HadeethEnc has not translated this hadith
  /// into yet, in HadeethEnc's own wording for that book and grade.
  final Map<String, ({String attribution, String grade})> sources;

  HeText? get arabic => byLang['ar'];

  /// The reader's language, or null while HadeethEnc has not translated it.
  HeText? translation(String lang) => lang == 'ar' ? null : byLang[lang];

  /// Title, book, grade and explanation in the reader's language, else Arabic.
  HeText? meta(String lang) {
    final t = byLang[lang];
    if (t != null && (t.attribution != null || t.explanation != null)) return t;
    if (sources[lang] case final s?) {
      final a = arabic;
      return HeText(
        text: a?.text ?? '',
        title: a?.title,
        attribution: s.attribution,
        grade: s.grade,
        explanation: a?.explanation,
        version: a?.version,
      );
    }
    return arabic;
  }

  Uri page(String lang) =>
      Uri.parse('https://hadeethenc.com/${byLang.containsKey(lang) ? lang : 'ar'}/browse/hadith/$id');
}

/// The hadiths Home, the checklists and the counter point to, bundled in
/// every app language (built by tool/build_content.py), so they open offline
/// and before the library is downloaded.
class HeBundle {
  const HeBundle(this.retrieved, this._items);
  final String retrieved;
  final Map<int, HeHadith> _items;

  HeHadith? operator [](int id) => _items[id];

  static HeBundle parse(String json) {
    final j = jsonDecode(json) as Map<String, Object?>;
    return HeBundle('${j['retrieved']}', {
      for (final MapEntry(:key, :value) in (j['items']! as Map<String, Object?>).entries)
        int.parse(key): HeHadith(
          int.parse(key),
          {
            for (final MapEntry(key: lang, :value) in (value! as Map<String, Object?>).entries)
              if (lang != 'src') lang: HeText.fromJson(value! as Map<String, Object?>),
          },
          {
            for (final MapEntry(key: lang, :value)
                in (((value as Map<String, Object?>)['src'] as Map<String, Object?>?) ?? const {}).entries)
              if (value case {'attribution': final String a, 'grade': final String g}) lang: (attribution: a, grade: g),
          },
        ),
    });
  }
}

final heBundleProvider = FutureProvider<HeBundle>(
  (ref) async => HeBundle.parse(await rootBundle.loadString('assets/sources/hadeethenc.json')),
);
