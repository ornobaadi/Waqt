import 'dhikr_data.dart';

/// One phrase to repeat. Built-in phrases and their HadeethEnc hadiths come
/// from tool/build_content.py, which checks every word against HadeethEnc's
/// Arabic; the user's own phrases are theirs.
class Dhikr {
  const Dhikr(
    this.id,
    this.arabic,
    this.latin,
    this.target, {
    this.he,
    this.virtue = const {},
    this.names = const {},
    this.custom = false,
  });
  final String id;
  final String? arabic;
  final String latin;
  final int target;

  /// HadeethEnc id of the hadith that teaches its virtue.
  final int? he;

  /// Our one-line summary of that virtue, per app language.
  final Map<String, String> virtue;

  /// How the phrase is written in a script other than Latin (Bangla).
  final Map<String, String> names;
  final bool custom;

  /// The phrase as the reader reads it: Arabic script for Arabic and Urdu,
  /// their own script where we have it, else the transliteration.
  String name(String lang) {
    if (custom) return latin;
    if ((lang == 'ar' || lang == 'ur') && arabic != null) return arabic!;
    return names[lang] ?? latin;
  }

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
  const DhikrRoutine(this.id, this.steps, {this.he, this.virtue = const {}});
  final String id;
  final List<Dhikr> steps;
  final int? he;
  final Map<String, String> virtue;
  bool get isSet => steps.length > 1;
  bool get custom => !isSet && steps.single.custom;

  String? virtueIn(String lang) => virtue[lang] ?? virtue['en'];
}

Dhikr _builtIn(String id) => builtInDhikr.firstWhere((d) => d.id == id);

/// The tasbih after salah, then every built-in phrase, the free count, and
/// the user's own phrases.
List<DhikrRoutine> routinesWith(List<Dhikr> custom) => [
  DhikrRoutine(
    'after_salah',
    [_builtIn('subhanallah'), _builtIn('alhamdulillah'), _builtIn('allahuakbar')],
    he: afterSalahHe,
    virtue: afterSalahVirtue,
  ),
  for (final d in builtInDhikr) DhikrRoutine(d.id, [d], he: d.he, virtue: d.virtue),
  const DhikrRoutine('free', [Dhikr('free', null, '', 33)]),
  for (final d in custom) DhikrRoutine(d.id, [d]),
];
