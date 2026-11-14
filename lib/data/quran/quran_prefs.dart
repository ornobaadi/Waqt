import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../user/user_prefs.dart';
import 'quran.dart';

/// How the Quran is read and heard. Kept on the phone.
class QuranPrefs {
  const QuranPrefs({
    this.arabicScale = 1,
    this.translation = true,
    this.follow = true,
    this.keepAwake = false,
    this.reciter = 'alafasy',
    this.mobileData = false,
    this.speed = 1,
    this.indoPak = false,
    this.transliteration = true,
    this.hintSeen = false,
  });

  /// The reader's one-time tip about double-tap and hold has been closed.
  final bool hintSeen;

  /// Show how to say each ayah in Latin letters.
  final bool transliteration;

  /// Read in the IndoPak script instead of the Uthmani.
  final bool indoPak;

  /// Arabic size, 0.8–1.8 of the default.
  final double arabicScale;

  /// Show the translation under each ayah.
  final bool translation;

  /// Scroll to the ayah being recited.
  final bool follow;

  /// Keep the screen on while the reader is open.
  final bool keepAwake;
  final String reciter;

  /// Stream and download on mobile data; otherwise Wi-Fi only.
  final bool mobileData;
  final double speed;

  QuranPrefs copyWith({
    double? arabicScale,
    bool? translation,
    bool? follow,
    bool? keepAwake,
    String? reciter,
    bool? mobileData,
    double? speed,
    bool? indoPak,
    bool? transliteration,
    bool? hintSeen,
  }) => QuranPrefs(
    arabicScale: arabicScale ?? this.arabicScale,
    translation: translation ?? this.translation,
    follow: follow ?? this.follow,
    keepAwake: keepAwake ?? this.keepAwake,
    reciter: reciter ?? this.reciter,
    mobileData: mobileData ?? this.mobileData,
    speed: speed ?? this.speed,
    indoPak: indoPak ?? this.indoPak,
    transliteration: transliteration ?? this.transliteration,
    hintSeen: hintSeen ?? this.hintSeen,
  );

  Map<String, Object> toJson() => {
    'arabic': arabicScale,
    'translation': translation,
    'follow': follow,
    'awake': keepAwake,
    'reciter': reciter,
    'mobile': mobileData,
    'speed': speed,
    'script': indoPak ? 'indopak' : 'uthmani',
    'translit': transliteration,
    'hint': hintSeen,
  };

  static QuranPrefs fromJson(Map<String, Object?> j) => QuranPrefs(
    arabicScale: (j['arabic'] as num?)?.toDouble() ?? 1,
    translation: j['translation'] as bool? ?? true,
    follow: j['follow'] as bool? ?? true,
    keepAwake: j['awake'] as bool? ?? false,
    reciter: j['reciter'] as String? ?? 'alafasy',
    mobileData: j['mobile'] as bool? ?? false,
    speed: (j['speed'] as num?)?.toDouble() ?? 1,
    indoPak: j['script'] == 'indopak',
    transliteration: j['translit'] as bool? ?? true,
    hintSeen: j['hint'] as bool? ?? false,
  );
}

class QuranPrefsNotifier extends Notifier<QuranPrefs> {
  static const _key = 'quran.prefs.v1';

  @override
  QuranPrefs build() {
    final raw = ref.read(sharedPrefsProvider).getString(_key);
    if (raw == null) return const QuranPrefs();
    try {
      return QuranPrefs.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on Object {
      return const QuranPrefs();
    }
  }

  void update(QuranPrefs Function(QuranPrefs) f) {
    state = f(state);
    ref.read(sharedPrefsProvider).setString(_key, jsonEncode(state.toJson()));
  }
}

final quranPrefsProvider = NotifierProvider<QuranPrefsNotifier, QuranPrefs>(QuranPrefsNotifier.new);

/// The Quran in the script the reader chose (Uthmani until IndoPak has loaded).
final quranTextProvider = Provider<Quran?>((ref) {
  final q = ref.watch(quranProvider).value;
  if (q == null || !ref.watch(quranPrefsProvider.select((p) => p.indoPak))) return q;
  final ip = ref.watch(indoPakProvider).value;
  return ip == null ? q : q.inIndoPak(ip);
});

/// Where you stopped reading, and the ayat you saved.
class QuranProgress {
  const QuranProgress({this.last, this.saved = const []});
  final AyahRef? last;

  /// Newest first.
  final List<AyahRef> saved;

  bool isSaved(AyahRef r) => saved.contains(r);
}

class QuranProgressNotifier extends Notifier<QuranProgress> {
  static const _key = 'quran.progress.v1';

  @override
  QuranProgress build() {
    final raw = ref.read(sharedPrefsProvider).getString(_key);
    if (raw == null) return const QuranProgress();
    try {
      final j = jsonDecode(raw) as Map<String, Object?>;
      AyahRef? ref(Object? v) => switch (v) {
        [final int s, final int a] => (surah: s, ayah: a),
        _ => null,
      };
      return QuranProgress(
        last: ref(j['last']),
        saved: [for (final v in (j['saved'] as List<Object?>?) ?? const []) ?ref(v)],
      );
    } on Object {
      return const QuranProgress();
    }
  }

  void _save() => ref
      .read(sharedPrefsProvider)
      .setString(
        _key,
        jsonEncode({
          if (state.last case final l?) 'last': [l.surah, l.ayah],
          'saved': [
            for (final s in state.saved) [s.surah, s.ayah],
          ],
        }),
      );

  void read(AyahRef r) {
    if (state.last == r) return;
    state = QuranProgress(last: r, saved: state.saved);
    _save();
  }

  void toggleSaved(AyahRef r) {
    final saved = [...state.saved];
    saved.contains(r) ? saved.remove(r) : saved.insert(0, r);
    state = QuranProgress(last: state.last, saved: saved);
    _save();
  }
}

final quranProgressProvider = NotifierProvider<QuranProgressNotifier, QuranProgress>(QuranProgressNotifier.new);
