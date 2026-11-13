import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../download/downloader.dart';
import '../sources/he_library.dart' show contentLangProvider;

/// A QuranEnc.com translation, as the King Fahd Complex / Rowwad teams
/// publish it: one file per translation, downloaded once, shown unchanged and
/// credited with its version.
class QuranTranslationInfo {
  const QuranTranslationInfo(this.key, this.translator);
  final String key;

  /// "Saheeh International", in its own language where that is how it is known.
  final String translator;

  Uri get file => Uri.parse('https://quranenc.com/downloads/sqlite/$key.zip');
  Uri get page => Uri.parse('https://quranenc.com/en/browse/$key');
}

/// One translation per app language. Arabic readers read the Arabic.
const quranTranslations = <String, QuranTranslationInfo>{
  'en': QuranTranslationInfo('english_rwwad', 'Rowwad Translation Center'),
  'ur': QuranTranslationInfo('urdu_junagarhi', 'محمد جوناگڑھی'),
  'bn': QuranTranslationInfo('bengali_zakaria', 'আবু বকর মুহাম্মাদ যাকারিয়া'),
  'id': QuranTranslationInfo('indonesian_affairs', 'Kementerian Agama RI'),
  'tr': QuranTranslationInfo('turkish_rwwad', 'Rowwad Tercüme Merkezi'),
  'fr': QuranTranslationInfo('french_rashid', 'Rachid Maach'),
};

/// One ayah's translation and its translator's notes.
typedef AyahTranslation = ({String text, String notes});

class QuranTranslation {
  QuranTranslation._(this.info, this._db, this.version);
  final QuranTranslationInfo info;
  final Database _db;

  /// QuranEnc's version of this file, when it told us.
  final String? version;

  static Future<String> _path(String key) async =>
      '${(await getApplicationSupportDirectory()).path}/quranenc-$key.sqlite';

  static Future<bool> isInstalled(String key) async => File(await _path(key)).existsSync();

  static Future<void> uninstall(String key) async {
    for (final f in [File(await _path(key)), File('${await _path(key)}.json')]) {
      if (f.existsSync()) await f.delete();
    }
  }

  /// Downloads and unpacks it; [onProgress] gets 0..1. Records QuranEnc's
  /// version beside it when the list of translations answers.
  static Future<void> install(
    QuranTranslationInfo info, {
    void Function(double)? onProgress,
    CancelToken? cancel,
  }) async {
    final path = await _path(info.key);
    final zip = File('$path.zip');
    await download(
      info.file,
      zip,
      cancel: cancel,
      onProgress: (got, total) => onProgress?.call(total > 0 ? (got / total).clamp(0, 0.95) : 0.5),
    );
    await compute(_unpack, (zip.path, path));
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
      final res = await (await client.getUrl(Uri.parse('https://quranenc.com/api/v1/translations/list'))).close();
      final list = jsonDecode(await res.transform(utf8.decoder).join()) as Map<String, Object?>;
      client.close();
      final t = (list['translations']! as List<Object?>).cast<Map<String, Object?>>().where(
        (t) => t['key'] == info.key,
      );
      if (t.isNotEmpty) {
        await File('$path.json')
            .writeAsString(jsonEncode({'version': t.first['version'], 'updated': t.first['last_update']}));
      }
    } on Object catch (e) {
      debugPrint('quranenc version unknown: $e');
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

  static Future<QuranTranslation> open(QuranTranslationInfo info) async {
    final path = await _path(info.key);
    String? version;
    final meta = File('$path.json');
    if (meta.existsSync()) version = '${(jsonDecode(await meta.readAsString()) as Map)['version']}';
    return fromDatabase(info, await openDatabase(path, readOnly: true), version: version);
  }

  static QuranTranslation fromDatabase(QuranTranslationInfo info, Database db, {String? version}) =>
      QuranTranslation._(info, db, version);

  /// A surah's translation, ayah number → text and notes.
  Future<Map<int, AyahTranslation>> surah(int n) async => {
    for (final r in await _db.query('translations', where: 'sura = ?', whereArgs: [n], orderBy: 'aya'))
      r['aya']! as int: (text: '${r['translation'] ?? ''}'.trim(), notes: '${r['footnotes'] ?? ''}'.trim()),
  };

  Future<void> close() => _db.close();
}

enum QuranTranslationStatus { none, checking, missing, downloading, ready, failed }

/// The translation for the app's language: on the phone or not, and progress.
class QuranTranslationInstall extends Notifier<({QuranTranslationStatus status, double progress})> {
  CancelToken? _cancel;

  @override
  ({QuranTranslationStatus status, double progress}) build() {
    final info = quranTranslations[ref.watch(contentLangProvider)];
    if (info == null) return (status: QuranTranslationStatus.none, progress: 0);
    QuranTranslation.isInstalled(info.key).then(
      (ok) =>
          state = (status: ok ? QuranTranslationStatus.ready : QuranTranslationStatus.missing, progress: ok ? 1 : 0),
      onError: (Object _) => state = (status: QuranTranslationStatus.failed, progress: 0),
    );
    return (status: QuranTranslationStatus.checking, progress: 0);
  }

  Future<void> download() async {
    final info = quranTranslations[ref.read(contentLangProvider)];
    if (info == null || state.status == QuranTranslationStatus.downloading) return;
    state = (status: QuranTranslationStatus.downloading, progress: 0);
    _cancel = CancelToken();
    try {
      await QuranTranslation.install(
        info,
        cancel: _cancel,
        onProgress: (p) => state = (status: QuranTranslationStatus.downloading, progress: p),
      );
      state = (status: QuranTranslationStatus.ready, progress: 1);
    } on Object catch (e) {
      debugPrint('quran translation download failed: $e');
      state = (status: QuranTranslationStatus.failed, progress: 0);
    }
  }

  void cancel() => _cancel?.cancel();

  Future<void> remove() async {
    final info = quranTranslations[ref.read(contentLangProvider)];
    if (info == null) return;
    ref.invalidate(quranTranslationProvider);
    await QuranTranslation.uninstall(info.key);
    state = (status: QuranTranslationStatus.missing, progress: 0);
  }
}

final quranTranslationInstallProvider =
    NotifierProvider<QuranTranslationInstall, ({QuranTranslationStatus status, double progress})>(
      QuranTranslationInstall.new,
    );

/// The open translation, or null while there is none on the phone.
final quranTranslationProvider = FutureProvider<QuranTranslation?>((ref) async {
  final info = quranTranslations[ref.watch(contentLangProvider)];
  final ready = ref.watch(quranTranslationInstallProvider.select((s) => s.status == QuranTranslationStatus.ready));
  if (info == null || !ready) return null;
  final t = await QuranTranslation.open(info);
  ref.onDispose(t.close);
  return t;
});

/// One surah of the open translation.
final surahTranslationProvider = FutureProvider.family<Map<int, AyahTranslation>, int>((ref, n) async {
  final t = await ref.watch(quranTranslationProvider.future);
  return t == null ? const {} : t.surah(n);
});
