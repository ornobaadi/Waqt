import 'dart:convert';

import 'referenced.dart';

export 'referenced.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/moments/moment.dart';
import '../../domain/occasions/occasions.dart';
import '../user/user_prefs.dart';

/// One thing the Sunnah teaches for a day, tied to the HadeethEnc hadith
/// that teaches it. The label is ours, in every app language.
class DayItem {
  const DayItem(this.titles, this.he, {this.when, this.key});
  final Map<String, String> titles;

  /// HadeethEnc.com id of the hadith; 0 for a [referenced] item.
  final int he;

  /// For the few items not on HadeethEnc: their key in [referencedDuas].
  final String? key;

  ReferencedDua? get referenced => key == null ? null : referencedDuas[key];

  /// When it matters most: 'suhoor', 'morning', 'day', 'iftar' or 'night'.
  final String? when;

  String title(String lang) => titles[lang] ?? titles['en'] ?? '';
  String get id => key != null ? 'ref:$key' : 'he:$he';
}

/// Built by tool/build_content.py from HadeethEnc.com; see that file.
class DayGuides {
  DayGuides(this._days, this.fasts, [this._moments = const {}]);
  final Map<OccasionId, List<DayItem>> _days;
  final Map<MomentId, List<DayItem>> _moments;

  /// Occasions on which fasting is the Sunnah.
  final Set<OccasionId> fasts;

  List<DayItem> forOccasion(OccasionId o) => _days[o] ?? const [];

  /// Sourced items for a moment of the day (built by tool/build_days.py).
  List<DayItem> forMoment(MomentId m) => _moments[m] ?? const [];

  /// Everything for the featured occasion. In the last ten nights the
  /// daily Ramadan practices still apply, so they follow.
  List<DayItem> itemsFor(OccasionId featured, List<OccasionId> occasions) => [
    ...forOccasion(featured),
    if (featured == OccasionId.lastTenNights && occasions.contains(OccasionId.ramadan))
      ...forOccasion(OccasionId.ramadan),
  ];

  /// The first occasion that has a guide, most specific first. Friday has its
  /// own checklist on Home, so it is left to that.
  OccasionId? featured(List<OccasionId> occasions) =>
      occasions.where((o) => o != OccasionId.jumuah && forOccasion(o).isNotEmpty).firstOrNull;

  static DayGuides parse(String json) {
    final j = jsonDecode(json) as Map<String, Object?>;
    List<DayItem> items(Object? v) => [
      for (final i in v! as List<Object?>)
        if (i case final Map<String, Object?> m)
          DayItem(
            {for (final MapEntry(:key, :value) in (m['title']! as Map<String, Object?>).entries) key: '$value'},
            m['he']! as int,
            when: m['when'] as String?,
            key: m['key'] as String?,
          ),
    ];
    final occ = OccasionId.values.asNameMap(), mom = MomentId.values.asNameMap();
    return DayGuides(
      {for (final MapEntry(:key, :value) in (j['days']! as Map<String, Object?>).entries) ?occ[key]: items(value)},
      {for (final f in j['fasts']! as List<Object?>) ?occ[f]},
      {
        for (final MapEntry(:key, :value) in ((j['moments'] as Map<String, Object?>?) ?? const {}).entries)
          ?mom[key]: items(value),
      },
    );
  }
}

final dayGuidesProvider = FutureProvider<DayGuides>(
  (ref) async => DayGuides.parse(await rootBundle.loadString('assets/sources/days.json')),
);

/// Ticks on a day's guide, kept for that civil date only.
class DayTicks extends Notifier<({String day, Set<String> done})> {
  static const _key = 'dayticks.v1';

  @override
  ({String day, Set<String> done}) build() {
    final raw = ref.read(sharedPrefsProvider).getStringList(_key);
    if (raw == null || raw.isEmpty) return (day: '', done: const {});
    return (day: raw.first, done: raw.skip(1).toSet());
  }

  Set<String> doneOn(String day) => state.day == day ? state.done : const {};

  void toggle(String day, String id) {
    final done = {...doneOn(day)};
    done.contains(id) ? done.remove(id) : done.add(id);
    state = (day: day, done: done);
    ref.read(sharedPrefsProvider).setStringList(_key, [day, ...done]);
  }
}

final dayTicksProvider = NotifierProvider<DayTicks, ({String day, Set<String> done})>(DayTicks.new);
