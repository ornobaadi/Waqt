import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One hadith in one language, exactly as HadeethEnc.com publishes it.
class HeText {
  const HeText({required this.text, this.title, this.attribution, this.grade, this.explanation});
  final String text;
  final String? title, attribution, grade, explanation;
}

/// HadeethEnc's entry for one of our references, in every language it has.
class HeEntry {
  const HeEntry(this.id, this.byLang);
  final String id;
  final Map<String, HeText> byLang;

  HeText? of(String lang) => byLang[lang];

  Uri page(String lang) =>
      Uri.parse('https://hadeethenc.com/${byLang.containsKey(lang) ? lang : 'en'}/browse/hadith/$id');
}

/// Reviewed translations (and explanations) for the hadiths the app shows,
/// built by tool/import_hadeethenc.py. Keyed by our reference 'col:num'.
class HadeethEnc {
  const HadeethEnc(this.retrieved, this._items);
  final String retrieved;
  final Map<String, HeEntry> _items;

  HeEntry? operator [](String ref) => _items[ref];

  static HadeethEnc parse(String json) {
    final j = jsonDecode(json) as Map<String, Object?>;
    final items = <String, HeEntry>{};
    for (final MapEntry(:key, :value) in (j['items']! as Map<String, Object?>).entries) {
      final m = value! as Map<String, Object?>;
      items[key] = HeEntry('${m['heId']}', {
        for (final MapEntry(key: lang, :value) in m.entries)
          if (value case {'hadeeth': final String text})
            lang: HeText(
              text: text,
              title: value['title'] as String?,
              attribution: value['attribution'] as String?,
              grade: value['grade'] as String?,
              explanation: value['explanation'] as String?,
            ),
      });
    }
    return HadeethEnc('${j['retrieved']}', items);
  }
}

final hadeethEncProvider = FutureProvider<HadeethEnc>(
  (ref) async => HadeethEnc.parse(await rootBundle.loadString('assets/sources/hadeethenc.json')),
);
