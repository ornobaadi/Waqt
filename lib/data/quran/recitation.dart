import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../download/downloader.dart';
import 'quran.dart';

/// A reciter whose recitation EveryAyah.com publishes ayah by ayah.
class Reciter {
  const Reciter(this.id, this.name, this.arabic, this.folder, {this.mujawwad = false});
  final String id;
  final String name;
  final String arabic;

  /// EveryAyah's folder, as in `https://everyayah.com/data/<folder>/SSSAAA.mp3`.
  final String folder;
  final bool mujawwad;

  Uri url(int surah, int ayah) =>
      Uri.parse('https://everyayah.com/data/$folder/${'$surah'.padLeft(3, '0')}${'$ayah'.padLeft(3, '0')}.mp3');
}

/// Hafs 'an 'Asim, murattal. Audio is streamed from EveryAyah or kept on the
/// phone after a download; Waqt never hosts it.
const reciters = [
  Reciter('alafasy', 'Mishary Rashid Alafasy', 'مشاري راشد العفاسي', 'Alafasy_64kbps'),
  Reciter('husary', 'Mahmoud Khalil Al-Husary', 'محمود خليل الحصري', 'Husary_64kbps'),
  Reciter('abdulbasit', 'Abdul Basit Abdus Samad', 'عبد الباسط عبد الصمد', 'Abdul_Basit_Murattal_64kbps'),
  Reciter('ghamdi', 'Saad Al-Ghamdi', 'سعد الغامدي', 'Ghamadi_40kbps'),
  Reciter('muaiqly', 'Maher Al-Muaiqly', 'ماهر المعيقلي', 'Maher_AlMuaiqly_64kbps'),
];

Reciter reciterById(String id) => reciters.firstWhere((r) => r.id == id, orElse: () => reciters.first);

/// What plays for a surah, in order: the basmala first where the surah has
/// one (EveryAyah's 001001), then each ayah. Ayah 0 is the basmala.
List<int> recitedAyahs(Quran q, int surah) => [
  if (q.hasBasmalaHeading(surah)) 0,
  for (var a = 1; a <= q.surah(surah).ayahs; a++) a,
];

/// Recitations kept on the phone, per reciter and surah.
class RecitationStore {
  RecitationStore(this.root);
  final Directory root;

  static Future<RecitationStore> open() async =>
      RecitationStore(Directory('${(await getApplicationSupportDirectory()).path}/recitation'));

  Directory _surah(Reciter r, int s) => Directory('${root.path}/${r.folder}/${'$s'.padLeft(3, '0')}');

  /// The local file for an ayah (0 = basmala), whether or not it is there.
  File file(Reciter r, int surah, int ayah) {
    final (s, a) = ayah == 0 ? (1, 1) : (surah, ayah);
    return File('${_surah(r, surah).path}/${'$s'.padLeft(3, '0')}${'$a'.padLeft(3, '0')}.mp3');
  }

  /// A surah counts as downloaded once every file it needs is there.
  bool isDownloaded(Quran q, Reciter r, int surah) =>
      recitedAyahs(q, surah).every((a) => file(r, surah, a).existsSync());

  Set<int> downloaded(Quran q, Reciter r) => {
    for (var s = 1; s <= 114; s++)
      if (_surah(r, s).existsSync() && isDownloaded(q, r, s)) s,
  };

  int bytes(Reciter r) {
    final d = Directory('${root.path}/${r.folder}');
    if (!d.existsSync()) return 0;
    return d.listSync(recursive: true).whereType<File>().fold(0, (n, f) => n + f.lengthSync());
  }

  Future<void> remove(Reciter r, int surah) async {
    final d = _surah(r, surah);
    if (d.existsSync()) await d.delete(recursive: true);
  }

  /// Fetches every file of a surah not yet on the phone. [onProgress] gets
  /// files done and files needed.
  Future<void> downloadSurah(
    Quran q,
    Reciter r,
    int surah, {
    void Function(int done, int total)? onProgress,
    CancelToken? cancel,
  }) async {
    final ayahs = recitedAyahs(q, surah);
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      var done = 0;
      for (final a in ayahs) {
        if (cancel?.cancelled ?? false) throw const DownloadCancelled();
        final f = file(r, surah, a);
        if (!f.existsSync()) {
          await download(r.url(a == 0 ? 1 : surah, a == 0 ? 1 : a), f, client: client, cancel: cancel);
        }
        onProgress?.call(++done, ayahs.length);
      }
    } finally {
      client.close();
    }
  }
}

final recitationStoreProvider = FutureProvider<RecitationStore>((ref) => RecitationStore.open());
