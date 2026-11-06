import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/moments/moment.dart';
import 'user_prefs.dart';

/// Ticked items for one prayer day. A new prayer day (next Fajr) starts
/// empty: the "daily reset" is just a key change, no timers needed.
class ChecklistState {
  const ChecklistState(this.day, this.done);
  final String day;
  final Map<String, Set<String>> done;

  Set<String> doneFor(String day, MomentId m) => day == this.day ? (done[m.name] ?? const {}) : const {};
}

String prayerDayKey(DateTime fajr) =>
    '${fajr.year.toString().padLeft(4, '0')}-${fajr.month.toString().padLeft(2, '0')}-${fajr.day.toString().padLeft(2, '0')}';

class ChecklistNotifier extends Notifier<ChecklistState> {
  static const _key = 'checklist.v1';

  @override
  ChecklistState build() {
    final raw = ref.read(sharedPrefsProvider).getString(_key);
    if (raw == null) return const ChecklistState('', {});
    try {
      final j = jsonDecode(raw) as Map<String, Object?>;
      final done = (j['done']! as Map<String, Object?>).map(
        (k, v) => MapEntry(k, (v! as List<Object?>).cast<String>().toSet()),
      );
      return ChecklistState(j['day']! as String, done);
    } on Object {
      return const ChecklistState('', {});
    }
  }

  void toggle(String day, MomentId moment, String itemId) {
    final done = day == state.day
        ? {
            for (final e in state.done.entries) e.key: {...e.value},
          }
        : <String, Set<String>>{};
    final set = done.putIfAbsent(moment.name, () => {});
    if (!set.remove(itemId)) set.add(itemId);
    state = ChecklistState(day, done);
    ref
        .read(sharedPrefsProvider)
        .setString(_key, jsonEncode({'day': day, 'done': done.map((k, v) => MapEntry(k, v.toList()))}));
  }
}

final checklistProvider = NotifierProvider<ChecklistNotifier, ChecklistState>(ChecklistNotifier.new);

/// Moments that present their content as a tick-off list.
const checklistMoments = {MomentId.bedtime, MomentId.jumuah};
