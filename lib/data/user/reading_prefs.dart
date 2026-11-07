import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_prefs.dart';

/// How large the three layers of a dua are read: Arabic, transliteration and
/// meaning, each set on its own. Scales of the default size, 0.8–1.8.
class ReadingPrefs {
  const ReadingPrefs({this.arabic = 1, this.transliteration = 1, this.meaning = 1});
  final double arabic;
  final double transliteration;
  final double meaning;

  static const min = 0.8, max = 1.8;

  /// Applies a scale to a style, keeping line height proportional.
  static TextStyle scaled(TextStyle s, double k) => s.copyWith(fontSize: (s.fontSize ?? 16) * k);
}

class ReadingPrefsNotifier extends Notifier<ReadingPrefs> {
  static const _a = 'reading.arabic.v1', _t = 'reading.translit.v1', _m = 'reading.meaning.v1';

  @override
  ReadingPrefs build() {
    final sp = ref.read(sharedPrefsProvider);
    return ReadingPrefs(
      arabic: sp.getDouble(_a) ?? 1,
      transliteration: sp.getDouble(_t) ?? 1,
      meaning: sp.getDouble(_m) ?? 1,
    );
  }

  void set({double? arabic, double? transliteration, double? meaning}) {
    state = ReadingPrefs(
      arabic: arabic ?? state.arabic,
      transliteration: transliteration ?? state.transliteration,
      meaning: meaning ?? state.meaning,
    );
    final sp = ref.read(sharedPrefsProvider);
    sp.setDouble(_a, state.arabic);
    sp.setDouble(_t, state.transliteration);
    sp.setDouble(_m, state.meaning);
  }

  void reset() => set(arabic: 1, transliteration: 1, meaning: 1);
}

final readingPrefsProvider = NotifierProvider<ReadingPrefsNotifier, ReadingPrefs>(ReadingPrefsNotifier.new);
