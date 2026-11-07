import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
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
/// APK small). On first use it is unpacked and indexed once, which takes a
/// few seconds and reports progress.
class HadithDb {
  HadithDb._(this._db, this.collections);
  final Database _db;
  final List<HadithCollection> collections;

  static const _file = 'hadith-v1.db';
  static const _ready = 'index_ready';

  static Future<HadithDb> open({void Function(double)? onProgress}) async {
    final dir = await getApplicationSupportDirectory();
    final path = '${dir.path}/$_file';
    if (!File(path).existsSync()) {
      final gz = await rootBundle.load('assets/sources/hadith.db.gz');
      final bytes = gzip.decode(gz.buffer.asUint8List(gz.offsetInBytes, gz.lengthInBytes));
      await File('$path.tmp').writeAsBytes(bytes, flush: true);
      await File('$path.tmp').rename(path);
    }
    return fromDatabase(await openDatabase(path), onProgress: onProgress);
  }

  /// Index (if needed) and wrap an open database. Tests use it directly.
  static Future<HadithDb> fromDatabase(Database db, {void Function(double)? onProgress}) async {
    await _index(db, onProgress);
    final cols = await db.query('collection', orderBy: 'ord');
    return HadithDb._(db, [
      for (final c in cols)
        HadithCollection(c['id']! as String, '${c['name_en']}', '${c['name_ar']}', c['count']! as int),
    ]);
  }

  static Future<void> _index(Database db, void Function(double)? onProgress) async {
    await db.execute('CREATE TABLE IF NOT EXISTS meta(k TEXT PRIMARY KEY, v TEXT)');
    final done = await db.query('meta', where: 'k = ?', whereArgs: [_ready]);
    if (done.isNotEmpty) return;
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
      final batch = db.batch();
      for (final r in rows) {
        batch.rawInsert('INSERT INTO hadith_fts(rowid, ar, en) VALUES(?,?,?)', [
          r['id'],
          SearchText.normalize(r['ar'] as String?),
          SearchText.normalize('${r['en'] ?? ''} ${r['ref'] ?? ''}'),
        ]);
      }
      await batch.commit(noResult: true);
      onProgress?.call((off + rows.length) / total);
    }
    await db.insert('meta', {'k': _ready, 'v': '1'});
  }

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
    final match = words.map((w) => '$w*').join(' ');
    final rows = await _db.rawQuery(
      'SELECT h.* FROM hadith_fts f JOIN hadith h ON h.id = f.rowid '
      'WHERE hadith_fts MATCH ? ${collection == null ? '' : 'AND h.col = ?'} ORDER BY h.id LIMIT $limit',
      [match, ?collection],
    );
    return rows.map(Hadith.fromRow).toList();
  }
}

/// Indexing progress on first open, 0..1; null once ready.
final hadithIndexProgressProvider = NotifierProvider<_Progress, double?>(_Progress.new);

class _Progress extends Notifier<double?> {
  @override
  double? build() => 0;
  void set(double? v) => state = v;
}

final hadithDbProvider = FutureProvider<HadithDb>((ref) async {
  final p = ref.read(hadithIndexProgressProvider.notifier);
  final db = await HadithDb.open(onProgress: p.set);
  p.set(null);
  return db;
});
