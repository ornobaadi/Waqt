import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/moments/moment.dart';
import '../../domain/occasions/occasions.dart';
import '../user/user_prefs.dart';

/// One thing the Sunnah teaches for a day, tied to the hadith that teaches it.
class DayItem {
  const DayItem(this.title, this.collection, this.number, this.reference, this.grade, {this.when});
  final String title;

  /// When it matters most: 'suhoor', 'day', 'iftar' or 'night'; null = any time.
  final String? when;
  final String collection;
  final String number;
  final String reference;
  final String? grade;

  String get id => '$collection:$number';
}

/// Built by tool/build_days.py from the hadith database; see that file.
class DayGuides {
  DayGuides(this._days, this.fasts);
  final Map<OccasionId, List<DayItem>> _days;

  /// Occasions on which fasting is the Sunnah.
  final Set<OccasionId> fasts;

  List<DayItem> forOccasion(OccasionId o) => _days[o] ?? const [];

  /// Sourced items for a moment of the day, by hadith reference.
  List<DayItem> forMoment(MomentId m) => [for (final id in momentItems[m] ?? const <String>[]) ?_byId[id]];

  late final Map<String, DayItem> _byId = {
    for (final list in _days.values)
      for (final i in list) i.id: i,
  };

  /// Which day items speak to which moment. Every id must exist in days.json
  /// (checked by a test).
  static const momentItems = <MomentId, List<String>>{
    MomentId.suhoor: ['bukhari:1923', 'bukhari:1921'],
    MomentId.iftar: ['tirmidhi:3598', 'bukhari:1957', 'abudawud:2356', 'abudawud:2357', 'tirmidhi:807'],
    MomentId.taraweeh: ['bukhari:2009', 'bukhari:6'],
    MomentId.laylatAlQadr: ['bukhari:2014', 'tirmidhi:3513', 'bukhari:2024'],
  };

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
    final byName = {for (final o in OccasionId.values) o.name: o};
    final days = <OccasionId, List<DayItem>>{};
    for (final MapEntry(:key, :value) in (j['days']! as Map<String, Object?>).entries) {
      final o = byName[key];
      if (o == null) continue;
      days[o] = [
        for (final i in value! as List<Object?>)
          if (i case final Map<String, Object?> m)
            DayItem(
              m['title']! as String,
              m['col']! as String,
              m['num']! as String,
              m['ref']! as String,
              m['grade'] as String?,
              when: m['when'] as String?,
            ),
      ];
    }
    return DayGuides(days, {for (final f in j['fasts']! as List<Object?>) ?byName[f]});
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
