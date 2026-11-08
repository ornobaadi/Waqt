import '../../data/sources/referenced.dart';
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
    this.reference,
  });
  final String id;
  final String? arabic;
  final String latin;
  final int target;

  /// HadeethEnc id of the hadith that teaches its virtue.
  final int? he;

  /// For a dhikr not on HadeethEnc: its own reference, per language.
  final Map<String, String>? reference;

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
  const DhikrRoutine(this.id, this.steps, {this.he, this.virtue = const {}, this.reference});
  final Map<String, String>? reference;
  String? referenceIn(String lang) => reference == null ? null : (reference![lang] ?? reference!['en']);
  final String id;
  final List<Dhikr> steps;
  final int? he;
  final Map<String, String> virtue;
  bool get isSet => steps.length > 1;
  bool get custom => !isSet && steps.single.custom;

  String? virtueIn(String lang) => virtue[lang] ?? virtue['en'];
}

Dhikr _builtIn(String id) => allBuiltInDhikr.firstWhere((d) => d.id == id);

/// The tasbih after salah, then every built-in phrase, the free count, and
/// the user's own phrases.
List<DhikrRoutine> routinesWith(List<Dhikr> custom) => [
  DhikrRoutine(
    'after_salah',
    [_builtIn('subhanallah'), _builtIn('alhamdulillah'), _builtIn('allahuakbar')],
    he: afterSalahHe,
    virtue: afterSalahVirtue,
  ),
  for (final d in allBuiltInDhikr) DhikrRoutine(d.id, [d], he: d.he, virtue: d.virtue, reference: d.reference),
  const DhikrRoutine('free', [Dhikr('free', null, '', 33)]),
  for (final d in custom) DhikrRoutine(d.id, [d]),
];

/// Built-in dhikr that are not on HadeethEnc, each with its own reference.
const referencedDhikr = <Dhikr>[
  // Not on HadeethEnc: the reference is shown in its place.
  Dhikr(
    'qadr',
    'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
    "Allahumma innaka 'afuwwun tuhibbul-'afwa fa'fu 'anni",
    33,
    names: {'bn': "আল্লাহুম্মা ইন্নাকা আফুউউন তুহিব্বুল আফওয়া ফা'ফু আন্নি"},
    virtue: {
      'en': 'For Laylat al-Qadr, taught to Aisha (RA): O Allah, You pardon and love to pardon, so pardon me',
      'ar': 'دعاء ليلة القدر، علّمه النبي ﷺ عائشة رضي الله عنها',
      'ur': 'لیلۃ القدر کی دعا، جو نبی ﷺ نے عائشہ رضی اللہ عنہا کو سکھائی',
      'bn': 'লাইলাতুল কদরের দোয়া, নবী ﷺ আয়েশা (রা.)-কে শিখিয়েছেন: হে আল্লাহ, আপনি ক্ষমাশীল, ক্ষমা ভালোবাসেন, আমাকে ক্ষমা করুন',
      'id': 'Doa Lailatul Qadar yang diajarkan Nabi ﷺ kepada Aisyah r.a.: Ya Allah, Engkau Maha Pemaaf dan suka memaafkan, maafkanlah aku',
      'tr':
          "Kadir Gecesi duası, Peygamber ﷺ Hz. Âişe'ye öğretti: Allah'ım, affedicisin, affetmeyi seversin, beni affet",
      'fr': "Pour Laylat al-Qadr, enseignée à Aïcha (qu'Allah l'agrée) : Ô Allah, Tu pardonnes et aimes le pardon, pardonne-moi",
    },
    reference: qadrDuaReference,
  ),
];

/// Every built-in dhikr, generated ones first.
const allBuiltInDhikr = [...builtInDhikr, ...referencedDhikr];
