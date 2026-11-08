/// Sourced items that are not on HadeethEnc.com, each with its own
/// reference. Kept to the very few that matter and are well authenticated.
class ReferencedDua {
  const ReferencedDua({
    required this.arabic,
    required this.latin,
    required this.meaning,
    required this.context,
    required this.reference,
  });

  final String arabic;
  final String latin;

  /// What the dua means, per app language.
  final Map<String, String> meaning;

  /// Who taught it and when, per app language.
  final Map<String, String> context;

  /// Where it is narrated and its grade, per app language.
  final Map<String, String> reference;

  String meaningIn(String lang) => meaning[lang] ?? meaning['en']!;
  String contextIn(String lang) => context[lang] ?? context['en']!;
  String referenceIn(String lang) => reference[lang] ?? reference['en']!;
}

/// The dua for Laylat al-Qadr. ʿĀʾishah (RA) asked the Prophet ﷺ what to
/// say if she knew which night it was; he taught her this.
/// Jāmiʿ al-Tirmidhī 3513 (he graded it hasan sahih) and Sunan Ibn Mājah
/// 3850; graded sahih by al-Albānī. The longer "ʿafuwwun karīm" wording is
/// not in the authenticated narrations, so it is not used here.
const qadrDua = ReferencedDua(
  arabic: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
  latin: "Allahumma innaka 'afuwwun tuhibbul-'afwa fa'fu 'anni",
  meaning: {
    'en': 'O Allah, You are the One who pardons, and You love to pardon, so pardon me.',
    'ar': 'اللهم إنك كثير العفو تحب العفو، فاعفُ عني.',
    'ur': 'اے اللہ! تو بہت معاف کرنے والا ہے، معاف کرنا پسند کرتا ہے، پس مجھے معاف فرما دے۔',
    'bn': 'হে আল্লাহ, আপনি ক্ষমাশীল, ক্ষমা করতে ভালোবাসেন, অতএব আমাকে ক্ষমা করুন।',
    'id': 'Ya Allah, sesungguhnya Engkau Maha Pemaaf dan suka memaafkan, maka maafkanlah aku.',
    'tr': "Allah'ım! Sen affedicisin, affetmeyi seversin; beni de affet.",
    'fr': 'Ô Allah, Tu es Celui qui pardonne et Tu aimes le pardon, alors pardonne-moi.',
  },
  context: {
    'en': 'Aisha (RA) asked: if I knew which night is Laylat al-Qadr, what should I say? The Prophet ﷺ said: say this.',
    'ar': 'قالت عائشة رضي الله عنها: يا رسول الله، أرأيت إن علمت أي ليلة ليلة القدر ما أقول فيها؟ قال ﷺ: قولي هذا.',
    'ur': 'عائشہ رضی اللہ عنہا نے پوچھا: اگر مجھے معلوم ہو جائے کہ کون سی رات لیلۃ القدر ہے تو کیا کہوں؟ نبی ﷺ نے فرمایا: یہ کہو۔',
    'bn': 'আয়েশা (রা.) জিজ্ঞেস করলেন: যদি জানতে পারি কোন রাতটি লাইলাতুল কদর, তাতে কী বলব? নবী ﷺ বললেন: এটি বলো।',
    'id': 'Aisyah r.a. bertanya: jika aku tahu malam mana Lailatul Qadar, apa yang kuucapkan? Nabi ﷺ bersabda: ucapkanlah ini.',
    'tr': 'Hz. Âişe sordu: Hangi gecenin Kadir Gecesi olduğunu bilirsem ne diyeyim? Peygamber ﷺ: Şunu söyle, buyurdu.',
    'fr': "Aïcha (qu'Allah l'agrée) demanda : si je sais quelle nuit est Laylat al-Qadr, que dois-je dire ? Le Prophète ﷺ dit : dis ceci.",
  },
  reference: qadrDuaReference,
);

/// Referenced items by the key they carry in days.json.
const referencedDuas = {'qadrDua': qadrDua};

/// Where the Laylat al-Qadr dua is narrated, and its grade.
const qadrDuaReference = {
  'en': 'Tirmidhi 3513, Ibn Majah 3850 · Authentic',
  'ar': 'رواه الترمذي (٣٥١٣) وابن ماجه (٣٨٥٠) · صحيح',
  'ur': 'ترمذی ۳۵۱۳، ابن ماجہ ۳۸۵۰ · صحیح',
  'bn': 'তিরমিজি ৩৫১৩, ইবনে মাজাহ ৩৮৫০ · সহিহ',
  'id': 'Tirmidzi 3513, Ibnu Majah 3850 · Sahih',
  'tr': 'Tirmizî 3513, İbn Mâce 3850 · Sahih',
  'fr': 'Tirmidhi 3513, Ibn Majah 3850 · Authentique',
};
