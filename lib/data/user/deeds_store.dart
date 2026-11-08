import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/deeds/deeds.dart';
import '../../domain/prayer/prayer_times_service.dart';
import 'user_prefs.dart';

/// Every day's deeds, on this phone only. One JSON blob per month
/// (`deeds.v1.yyyy-mm`), so a year of history is twelve small keys.
class DeedsNotifier extends Notifier<Map<String, DayLog>> {
  static const _prefix = 'deeds.v1.';

  @override
  Map<String, DayLog> build() {
    final sp = ref.read(sharedPrefsProvider);
    final out = <String, DayLog>{};
    for (final key in sp.getKeys().where((k) => k.startsWith(_prefix))) {
      try {
        final j = jsonDecode(sp.getString(key)!) as Map<String, Object?>;
        for (final e in j.entries) {
          out[e.key] = DayLog.fromJson(e.value! as Map<String, Object?>);
        }
      } on Object {
        // A damaged month is skipped, never fatal.
      }
    }
    return out;
  }

  DayLog day(String key) => state[key] ?? DayLog.empty;

  /// Set or clear one prayer's mark.
  void markSalah(String day, Waqt prayer, SalahMark? mark) {
    final log = this.day(day);
    final salah = {...log.salah};
    if (mark == null) {
      salah.remove(prayer);
    } else {
      salah[prayer] = mark;
    }
    _put(day, log.copyWith(salah: salah));
  }

  void setFast(String day, bool? fasted) => _put(day, this.day(day).copyWith(fast: fasted));

  void setHabit(String day, String habit, int amount) {
    final habits = {...this.day(day).habits};
    if (amount <= 0) {
      habits.remove(habit);
    } else {
      habits[habit] = amount;
    }
    _put(day, this.day(day).copyWith(habits: habits));
  }

  void _put(String day, DayLog log) {
    final next = {...state};
    if (log.isEmpty) {
      next.remove(day);
    } else {
      next[day] = log;
    }
    state = next;
    final month = day.substring(0, 7);
    final key = '$_prefix$month';
    final logs = {
      for (final e in next.entries)
        if (e.key.startsWith(month)) e.key: e.value.toJson(),
    };
    final sp = ref.read(sharedPrefsProvider);
    if (logs.isEmpty) {
      sp.remove(key);
    } else {
      sp.setString(key, jsonEncode(logs));
    }
  }
}

final deedsProvider = NotifierProvider<DeedsNotifier, Map<String, DayLog>>(DeedsNotifier.new);

final deedStatsProvider = Provider<DeedStats>((ref) => DeedStats(ref.watch(deedsProvider)));

/// Whether the strip still shows what its colours mean. It hides by itself
/// after a few prayers are marked, or when dismissed.
class BeadHint extends Notifier<bool> {
  static const _key = 'deeds.hint.marks';
  static const _enough = 5;

  @override
  bool build() => (ref.read(sharedPrefsProvider).getInt(_key) ?? 0) < _enough;

  void marked() {
    final sp = ref.read(sharedPrefsProvider);
    final n = (sp.getInt(_key) ?? 0) + 1;
    sp.setInt(_key, n);
    if (n >= _enough) state = false;
  }

  void dismiss() {
    ref.read(sharedPrefsProvider).setInt(_key, _enough);
    state = false;
  }
}

final beadHintProvider = NotifierProvider<BeadHint, bool>(BeadHint.new);
