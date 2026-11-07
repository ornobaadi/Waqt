import '../../data/sources/days.dart';
import 'dhikr_data.dart';

/// The hadith that teaches a dhikr's virtue, in the hadith database.
class DhikrSource {
  const DhikrSource(this.collection, this.number, this.reference, this.grade);
  final String collection, number, reference;
  final String? grade;

  DayItem item(String title) => DayItem(title, collection, number, reference, grade);
}

/// One phrase to repeat. Built-in phrases and their virtues come from
/// tool/build_dhikr.py, which checks every word against the hadith database;
/// the user's own phrases are theirs.
class Dhikr {
  const Dhikr(this.id, this.arabic, this.latin, this.target, {this.virtue, this.source, this.custom = false});
  final String id;
  final String? arabic;
  final String latin;
  final int target;
  final String? virtue;
  final DhikrSource? source;
  final bool custom;

  Map<String, Object?> toJson() => {'id': id, 'ar': arabic, 'name': latin, 'target': target};

  static Dhikr? fromJson(Object? j) => switch (j) {
    {'id': final String id, 'name': final String name, 'target': final int target} => Dhikr(
      id,
      j['ar'] as String?,
      name,
      target,
      custom: true,
    ),
    _ => null,
  };
}

/// A routine: one dhikr, or a sequence said one after another.
class DhikrRoutine {
  const DhikrRoutine(this.id, this.steps, {this.virtue, this.source});
  final String id;
  final List<Dhikr> steps;
  final String? virtue;
  final DhikrSource? source;
  bool get isSet => steps.length > 1;
  bool get custom => !isSet && steps.single.custom;
}

Dhikr _builtIn(String id) => builtInDhikr.firstWhere((d) => d.id == id);

/// The tasbih after salah, then every built-in phrase, the free count, and
/// the user's own phrases.
List<DhikrRoutine> routinesWith(List<Dhikr> custom) => [
  DhikrRoutine(
    'after_salah',
    [_builtIn('subhanallah'), _builtIn('alhamdulillah'), _builtIn('allahuakbar')],
    virtue: afterSalahVirtue,
    source: afterSalahSource,
  ),
  for (final d in builtInDhikr) DhikrRoutine(d.id, [d], virtue: d.virtue, source: d.source),
  const DhikrRoutine('free', [Dhikr('free', null, '', 33)]),
  for (final d in custom) DhikrRoutine(d.id, [d]),
];
