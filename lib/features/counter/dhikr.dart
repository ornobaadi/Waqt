/// One phrase to repeat. These are the short, universally known formulas of
/// dhikr, named and written as they are said. Virtues and sources for each
/// come from the reviewed content bundle, never from here.
class Dhikr {
  const Dhikr(this.id, this.arabic, this.latin, this.target);
  final String id;
  final String? arabic;
  final String latin;
  final int target;
}

/// A routine: one dhikr, or a sequence said one after another.
class DhikrRoutine {
  const DhikrRoutine(this.id, this.steps);
  final String id;
  final List<Dhikr> steps;
  bool get isSet => steps.length > 1;
}

const _subhanallah = Dhikr('subhanallah', 'سُبْحَانَ اللّٰهِ', 'SubhanAllah', 33);
const _alhamdulillah = Dhikr('alhamdulillah', 'الْحَمْدُ لِلّٰهِ', 'Alhamdulillah', 33);
const _allahuakbar = Dhikr('allahuakbar', 'اللّٰهُ أَكْبَرُ', 'Allahu Akbar', 34);

const dhikrRoutines = [
  DhikrRoutine('after_salah', [_subhanallah, _alhamdulillah, _allahuakbar]),
  DhikrRoutine('subhanallah', [_subhanallah]),
  DhikrRoutine('alhamdulillah', [_alhamdulillah]),
  DhikrRoutine('allahuakbar', [_allahuakbar]),
  DhikrRoutine('tahlil', [Dhikr('tahlil', 'لَا إِلٰهَ إِلَّا اللّٰهُ', 'La ilaha illallah', 100)]),
  DhikrRoutine('istighfar', [Dhikr('istighfar', 'أَسْتَغْفِرُ اللّٰهَ', 'Astaghfirullah', 100)]),
  DhikrRoutine('salawat', [Dhikr('salawat', 'اللّٰهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ', 'Allahumma salli ala Muhammad', 10)]),
  DhikrRoutine('free', [Dhikr('free', null, '', 33)]),
];
