import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'search_text.dart';

class HadithCollection {
  const HadithCollection(this.id, this.nameEn, this.nameAr, this.count);
  final String id;
  final String nameEn;
  final String nameAr;
  final int count;
}

class Hadith {
  const Hadith({
    required this.collection,
    required this.number,
    required this.reference,
    required this.arabic,
    required this.english,
    this.grade,
    this.url,
  });
  final String collection;
  final String number;
  final String reference;
  final String arabic;
  final String english;

  /// As the source gives it. The two Sahihs carry none: their hadiths are
  /// sahih by the consensus of the scholars of hadith.
  final String? grade;
  final String? url;

  static Hadith fromRow(Map<String, Object?> r) => Hadith(
    collection: r['col']! as String,
    number: '${r['num'] ?? ''}',
    reference: '${r['ref'] ?? ''}',
    arabic: '${r['ar'] ?? ''}',
    english: '${r['en'] ?? ''}',
    grade: r['grade'] as String?,
    url: r['url'] as String?,
  );
}

/// Every hadith collection in open-hadith-data, searchable offline.
///
/// The asset is a compressed SQLite file without a search index (to keep the
/// APK small). Opening it unpacks it once, off the UI thread; lookups by
/// reference work straight away. The search index is built the first time
/// someone searches, with the text work done in a background isolate.
class HadithDb {
  HadithDb._(this._db, this.collections, this._onProgress);
  final Database _db;
  final List<HadithCollection> collections;
  final void Function(double)? _onProgress;
  Future<void>? _indexing;

  static const _file = 'hadith-v1.db';
  static const _ready = 'index_ready';

  /// The database is not in the app: it is downloaded once, on first use,
  /// from the public data repository, checked against this hash, and kept.
  static final url = Uri.parse('https://github.com/ornobaadi/waqt-data/releases/download/v1/hadith-v1.db.gz');
  static const sha256 = 'fe98ec60b39efa66c0f7cb2a8a5c2f20e8b30fac02c0852a149914532ae3f2de';
  static const downloadBytes = 13343045;

  static Future<String> _path() async => '${(await getApplicationSupportDirectory()).path}/$_file';

  static Future<bool> isInstalled() async => File(await _path()).existsSync();

  /// Downloads, verifies and unpacks the database. [onProgress] gets 0..1.
  static Future<void> install({void Function(double)? onProgress}) async {
    final path = await _path();
    final gz = File('$path.gz.part');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final res = await (await client.getUrl(url)).close();
      if (res.statusCode != 200) throw HttpException('HTTP ${res.statusCode}', uri: url);
      final total = res.contentLength > 0 ? res.contentLength : downloadBytes;
      final out = gz.openWrite();
      var got = 0;
      await for (final chunk in res) {
        out.add(chunk);
        got += chunk.length;
        onProgress?.call((got / total).clamp(0, 0.99));
      }
      await out.close();
    } finally {
      client.close();
    }
    // Hashing and unpacking 13 MB is CPU work: off the UI thread.
    await compute(_verifyAndUnpack, (gz.path, path));
    onProgress?.call(1);
  }

  static Future<void> _verifyAndUnpack((String, String) job) async {
    final (gzPath, path) = job;
    final gz = File(gzPath);
    final bytes = await gz.readAsBytes();
    if (crypto.sha256.convert(bytes).toString() != sha256) {
      await gz.delete();
      throw const FormatException('hadith download is corrupt');
    }
    final tmp = File('$path.tmp');
    await tmp.writeAsBytes(gzip.decode(bytes), flush: true);
    await tmp.rename(path);
    await gz.delete();
  }

  static Future<HadithDb> open({void Function(double)? onProgress}) async {
    final path = await _path();
    if (!File(path).existsSync()) throw StateError('hadith database not installed');
    return fromDatabase(await openDatabase(path), onProgress: onProgress);
  }

  /// Wrap an open database. Tests use it directly.
  static Future<HadithDb> fromDatabase(Database db, {void Function(double)? onProgress}) async {
    await db.execute('CREATE INDEX IF NOT EXISTS hadith_ref ON hadith(col, num)');
    final cols = await db.query('collection', orderBy: 'ord');
    return HadithDb._(db, [
      for (final c in cols)
        HadithCollection(c['id']! as String, '${c['name_en']}', '${c['name_ar']}', c['count']! as int),
    ], onProgress);
  }

  /// Builds the search index once; later calls return at once.
  Future<void> ensureIndex() => _indexing ??= _index(_db, _onProgress);

  static Future<void> _index(Database db, void Function(double)? onProgress) async {
    await db.execute('CREATE TABLE IF NOT EXISTS meta(k TEXT PRIMARY KEY, v TEXT)');
    final done = await db.query('meta', where: 'k = ?', whereArgs: [_ready]);
    if (done.isNotEmpty) {
      onProgress?.call(1);
      return;
    }
    await db.execute('DROP TABLE IF EXISTS hadith_fts');
    // Android's SQLite has FTS4; some desktop builds (tests) only FTS5. Both
    // take the same contentless table, inserts by rowid and prefix queries.
    try {
      await db.execute('CREATE VIRTUAL TABLE hadith_fts USING fts4(content="", ar, en, tokenize=simple)');
    } on DatabaseException {
      await db.execute("CREATE VIRTUAL TABLE hadith_fts USING fts5(ar, en, content='')");
    }
    final total = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM hadith')) ?? 1;
    const page = 2000;
    for (var off = 0; off < total; off += page) {
      final rows = await db.rawQuery('SELECT id, ar, en, ref FROM hadith LIMIT $page OFFSET $off');
      // Normalising Arabic is regex work: off the UI thread.
      final norm = await compute(_normalize, [
        for (final r in rows) [r['id'], r['ar'] as String? ?? '', '${r['en'] ?? ''} ${r['ref'] ?? ''}'],
      ]);
      final batch = db.batch();
      for (final r in norm) {
        batch.rawInsert('INSERT INTO hadith_fts(rowid, ar, en) VALUES(?,?,?)', r);
      }
      await batch.commit(noResult: true);
      onProgress?.call((off + rows.length) / total);
    }
    await db.insert('meta', {'k': _ready, 'v': '1'});
  }

  static List<List<Object?>> _normalize(List<List<Object?>> rows) => [
    for (final r in rows) [r[0], SearchText.normalize(r[1]! as String), SearchText.normalize(r[2]! as String)],
  ];

  /// One hadith by collection and number as the source numbers it.
  Future<Hadith?> byRef(String col, String num) async {
    final rows = await _db.query('hadith', where: 'col = ? AND num = ?', whereArgs: [col, num], limit: 1);
    return rows.isEmpty ? null : Hadith.fromRow(rows.first);
  }

  static final _refQuery = RegExp(r'^\s*([a-z\-]+)\s*:?\s*(\d+[a-z]?)\s*$', caseSensitive: false);
  static const _aliases = {
    'bukhari': 'bukhari',
    'muslim': 'muslim',
    'abudawud': 'abudawud',
    'abu-dawud': 'abudawud',
    'dawud': 'abudawud',
    'tirmidhi': 'tirmidhi',
    'nasai': 'nasai',
    'ibnmajah': 'ibnmajah',
    'majah': 'ibnmajah',
    'malik': 'malik',
    'muwatta': 'malik',
    'ahmad': 'ahmad',
    'darimi': 'darimi',
    'riyad': 'riyadussalihin',
    'riyadussalihin': 'riyadussalihin',
    'nawawi': 'nawawi40',
    'qudsi': 'qudsi40',
    'bulugh': 'bulugh',
    'adab': 'adab',
    'shamail': 'shamail',
    'mishkat': 'mishkat',
  };

  /// "bukhari 6324" goes straight to that hadith; anything else is a word
  /// search over Arabic, English and references, every word required.
  Future<List<Hadith>> search(String q, {String? collection, int limit = 60}) async {
    final ref = _refQuery.firstMatch(q);
    final alias = ref == null ? null : _aliases[ref.group(1)!.toLowerCase().replaceAll(' ', '')];
    if (alias != null) {
      final rows = await _db.query('hadith', where: 'col = ? AND num = ?', whereArgs: [alias, ref!.group(2)]);
      if (rows.isNotEmpty) return rows.map(Hadith.fromRow).toList();
    }
    final words = SearchText.words(q);
    if (words.isEmpty) return const [];
    await ensureIndex();
    final match = words.map((w) => '$w*').join(' ');
    final rows = await _db.rawQuery(
      'SELECT h.* FROM hadith_fts f JOIN hadith h ON h.id = f.rowid '
      'WHERE hadith_fts MATCH ? ${collection == null ? '' : 'AND h.col = ?'} ORDER BY h.id LIMIT $limit',
      [match, ?collection],
    );
    return rows.map(Hadith.fromRow).toList();
  }
}

/// Search-index progress while it is first built, 0..1; null otherwise.
final hadithIndexProgressProvider = NotifierProvider<_Progress, double?>(_Progress.new);

class _Progress extends Notifier<double?> {
  @override
  double? build() => null;
  void set(double? v) => state = v;
}

enum HadithLibrary { checking, missing, downloading, ready, failed }

/// Whether the hadith library is on the phone, and its download progress.
class HadithInstall extends Notifier<({HadithLibrary status, double progress})> {
  @override
  ({HadithLibrary status, double progress}) build() {
    HadithDb.isInstalled().then(
      (ok) => state = (status: ok ? HadithLibrary.ready : HadithLibrary.missing, progress: ok ? 1 : 0),
      onError: (Object _) => state = (status: HadithLibrary.failed, progress: 0),
    );
    return (status: HadithLibrary.checking, progress: 0);
  }

  Future<void> download() async {
    if (state.status == HadithLibrary.downloading || state.status == HadithLibrary.ready) return;
    state = (status: HadithLibrary.downloading, progress: 0);
    try {
      await HadithDb.install(onProgress: (p) => state = (status: HadithLibrary.downloading, progress: p));
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

final hadithDbProvider = FutureProvider<HadithDb>((ref) async {
  // Opens once the library is installed; until then, waits (never throws).
  final ready = ref.watch(hadithInstallProvider.select((s) => s.status == HadithLibrary.ready));
  if (!ready) return Completer<HadithDb>().future;
  final p = ref.read(hadithIndexProgressProvider.notifier);
  return HadithDb.open(onProgress: (v) => p.set(v >= 1 ? null : v));
});
