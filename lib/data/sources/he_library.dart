import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../app/app_state.dart';
import 'hadeethenc.dart';
import 'search_text.dart';

/// A HadeethEnc topic (category) in the reader's language.
class HeTopic {
  const HeTopic(this.id, this.title, this.parent, this.count);
  final int id;
  final String title;
  final int parent;
  final int count;
}

/// HadeethEnc's whole encyclopedia in one language: every hadith it has
/// translated into it, with the Arabic, grade, source and explanation, and its
/// topics. Downloaded once from hadeethenc.com, as HadeethEnc publishes it.
class HeLibrary {
  HeLibrary._(this.lang, this._db, this.topics);
  final String lang;
  final Database _db;
  final List<HeTopic> topics;

  static Uri url(String lang) => Uri.parse('https://hadeethenc.com/downloads/sqlite/$lang.sqlite.zip');

  static Future<String> _path(String lang) async =>
      '${(await getApplicationSupportDirectory()).path}/hadeethenc-$lang.sqlite';

  static Future<bool> isInstalled(String lang) async => File(await _path(lang)).existsSync();

  /// Test mode: remove it to try the first-use download again.
  static Future<void> uninstall(String lang) async {
    final f = File(await _path(lang));
    if (f.existsSync()) await f.delete();
  }

  /// Downloads and unpacks one language. [onProgress] gets 0..1.
  static Future<void> install(String lang, {void Function(double)? onProgress}) async {
    final path = await _path(lang);
    final zip = File('$path.zip.part');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final res = await (await client.getUrl(url(lang))).close();
      if (res.statusCode != 200) throw HttpException('HTTP ${res.statusCode}', uri: url(lang));
      final total = res.contentLength > 0 ? res.contentLength : 4000000;
      final out = zip.openWrite();
      var got = 0;
      await for (final chunk in res) {
        out.add(chunk);
        got += chunk.length;
        onProgress?.call((got / total).clamp(0, 0.95));
      }
      await out.close();
    } finally {
      client.close();
    }
    await compute(_unpack, (zip.path, path));
    final db = await openDatabase(path);
    try {
      await _index(db, lang);
    } finally {
      await db.close();
    }
    onProgress?.call(1);
  }

  static Future<void> _unpack((String, String) job) async {
    final (zipPath, path) = job;
    final zip = File(zipPath);
    final archive = ZipDecoder().decodeBytes(await zip.readAsBytes());
    final file = archive.files.firstWhere((f) => f.isFile && f.name.endsWith('.sqlite'));
    final tmp = File('$path.tmp');
    await tmp.writeAsBytes(file.content as List<int>, flush: true);
    await tmp.rename(path);
    await zip.delete();
  }

  /// A search column, normalised once: translation, Arabic and title.
  static Future<void> _index(Database db, String lang) async {
    final cols = {for (final r in await db.rawQuery('PRAGMA table_info(hadeeths)')) r['name']! as String};
    if (!cols.contains('q')) await db.execute('ALTER TABLE hadeeths ADD COLUMN q TEXT');
    final ar = cols.contains('hadeeth_ar') ? 'hadeeth_ar' : "''";
    final rows = await db.rawQuery('SELECT id, title, hadeeth, $ar AS ar FROM hadeeths');
    final norm = await compute(_normalize, [
      for (final r in rows) [r['id'], '${r['title'] ?? ''} ${r['hadeeth'] ?? ''} ${r['ar'] ?? ''}'],
    ]);
    final batch = db.batch();
    for (final r in norm) {
      batch.rawUpdate('UPDATE hadeeths SET q = ? WHERE id = ?', [r[1], r[0]]);
    }
    await batch.commit(noResult: true);
  }

  static List<List<Object?>> _normalize(List<List<Object?>> rows) => [
    for (final r in rows) [r[0], ' ${SearchText.normalize(r[1]! as String)} '],
  ];

  static Future<HeLibrary> open(String lang) async => fromDatabase(lang, await openDatabase(await _path(lang)));

  /// Wrap an open HadeethEnc database, adding the search column if missing.
  static Future<HeLibrary> fromDatabase(String lang, Database db) async {
    final cols = {for (final r in await db.rawQuery('PRAGMA table_info(hadeeths)')) r['name']! as String};
    if (!cols.contains('q')) await _index(db, lang);
    final count = {
      for (final r in await db.rawQuery('SELECT category_id c, COUNT(*) n FROM category_hadeeth GROUP BY category_id'))
        r['c']! as int: r['n']! as int,
    };
    final topics = [
      for (final r in await db.query('categories', orderBy: 'id'))
        HeTopic(r['id']! as int, '${r['title']}', (r['parent_id'] as int?) ?? 0, count[r['id']] ?? 0),
    ];
    return HeLibrary._(lang, db, topics);
  }

  HeHadith _row(Map<String, Object?> r) {
    final hasAr = r.containsKey('hadeeth_ar');
    HeText t(String? text) => HeText(
      text: text ?? '',
      title: r['title'] as String?,
      attribution: r['attribution'] as String?,
      grade: r['grade'] as String?,
      explanation: r['explanation'] as String?,
      version: (r['version'] ?? r['ar_version']) as int?,
    );
    return HeHadith(r['id']! as int, {
      if (hasAr) ...{
        'ar': HeText(text: '${r['hadeeth_ar'] ?? ''}'),
        lang: t(r['hadeeth'] as String?),
      } else
        'ar': t(r['hadeeth'] as String?),
    });
  }

  /// Every word must appear, in the translation, the Arabic or the title.
  Future<List<HeHadith>> search(String q, {int limit = 80}) async {
    final words = SearchText.words(q);
    if (words.isEmpty) return const [];
    final rows = await _db.query(
      'hadeeths',
      where: List.filled(words.length, 'q LIKE ?').join(' AND '),
      whereArgs: [for (final w in words) '%$w%'],
      limit: limit,
    );
    return rows.map(_row).toList();
  }

  /// Hadiths filed under a topic or any topic beneath it.
  Future<List<HeHadith>> inTopic(int id) async {
    final ids = <int>{id};
    for (var grew = true; grew;) {
      final before = ids.length;
      ids.addAll(topics.where((t) => ids.contains(t.parent)).map((t) => t.id));
      grew = ids.length != before;
    }
    final rows = await _db.rawQuery(
      'SELECT DISTINCT h.* FROM hadeeths h JOIN category_hadeeth c ON c.hadeeth_id = h.id '
      'WHERE c.category_id IN (${ids.join(',')}) ORDER BY h.id',
    );
    return rows.map(_row).toList();
  }

  List<HeTopic> children(int parent) => topics.where((t) => t.parent == parent).toList();
  HeTopic? topic(int id) => topics.where((t) => t.id == id).firstOrNull;

  Future<void> close() => _db.close();
}

enum HadithLibrary { checking, missing, downloading, ready, failed }

/// The library for the app's language: on the phone or not, and download progress.
class HadithInstall extends Notifier<({HadithLibrary status, double progress})> {
  @override
  ({HadithLibrary status, double progress}) build() {
    final lang = ref.watch(contentLangProvider);
    HeLibrary.isInstalled(lang).then(
      (ok) => state = (status: ok ? HadithLibrary.ready : HadithLibrary.missing, progress: ok ? 1 : 0),
      onError: (Object _) => state = (status: HadithLibrary.failed, progress: 0),
    );
    return (status: HadithLibrary.checking, progress: 0);
  }

  Future<void> download() async {
    if (state.status == HadithLibrary.downloading || state.status == HadithLibrary.ready) return;
    final lang = ref.read(contentLangProvider);
    state = (status: HadithLibrary.downloading, progress: 0);
    try {
      await HeLibrary.install(lang, onProgress: (p) => state = (status: HadithLibrary.downloading, progress: p));
      state = (status: HadithLibrary.ready, progress: 1);
    } on Object catch (e) {
      debugPrint('hadith download failed: $e');
      state = (status: HadithLibrary.failed, progress: 0);
    }
  }
}

final hadithInstallProvider = NotifierProvider<HadithInstall, ({HadithLibrary status, double progress})>(
  HadithInstall.new,
);

final heLibraryProvider = FutureProvider<HeLibrary>((ref) async {
  // Opens once installed; until then, waits (never throws).
  final ready = ref.watch(hadithInstallProvider.select((s) => s.status == HadithLibrary.ready));
  if (!ready) return Completer<HeLibrary>().future;
  final lib = await HeLibrary.open(ref.watch(contentLangProvider));
  ref.onDispose(lib.close);
  return lib;
});

/// The language hadith content is read in: the app's language.
final contentLangProvider = Provider<String>((ref) {
  const supported = {'en', 'ar', 'ur', 'bn', 'id', 'tr', 'fr'};
  final code = ref.watch(localeOverrideProvider)?.languageCode ?? PlatformDispatcher.instance.locale.languageCode;
  return supported.contains(code) ? code : 'en';
});
