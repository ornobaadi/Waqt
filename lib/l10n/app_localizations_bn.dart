// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'Waqt';

  @override
  String get navNow => 'এখন';

  @override
  String get navToday => 'আজ';

  @override
  String get navDuas => 'দোয়া';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get prayerFajr => 'ফজর';

  @override
  String get prayerSunrise => 'সূর্যোদয়';

  @override
  String get prayerDhuhr => 'যোহর';

  @override
  String get prayerAsr => 'আসর';

  @override
  String get prayerMaghrib => 'মাগরিব';

  @override
  String get prayerIsha => 'এশা';

  @override
  String get momentNight => 'রাত';

  @override
  String get momentBedtime => 'ঘুমানোর সময়';

  @override
  String get timePending => '–';

  @override
  String get nowLocationTitle => 'আপনি কোথায় নামাজ পড়েন?';

  @override
  String get nowLocationBody =>
      'আপনার অবস্থান থেকে নামাজের সময় আপনার ফোনেই হিসাব করা হয়। কোনো তথ্য ডিভাইসের বাইরে যায় না।';

  @override
  String get todayEmptyTitle => 'আপনার দিন, মুহূর্তে মুহূর্তে';

  @override
  String get todayEmptyBody =>
      'নামাজের সময় হিসাব হলে ফজর থেকে রাতের শেষ তৃতীয়াংশ পর্যন্ত আজকের প্রতিটি সময় এখানে সাজানো থাকবে।';

  @override
  String get duasEmptyTitle => 'শুধু যাচাইকৃত সূত্র';

  @override
  String get duasEmptyBody =>
      'প্রতিটি লেখা মূল সূত্রের সাথে মিলিয়ে দেখা এবং একজন আলেমের অনুমোদন পাওয়ার পর লাইব্রেরি খুলবে।';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsLanguageSystem => 'ডিভাইসের ভাষা';

  @override
  String get settingsDeveloper => 'Test mode';

  @override
  String get settingsDeveloperHint => 'Fake clock, day jumps and the reference checker';

  @override
  String get settingsAbout => 'Waqt সম্পর্কে';

  @override
  String settingsVersion(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get debugTitle => 'Test mode';

  @override
  String get debugClock => 'Clock';

  @override
  String get debugClockReal => 'Real time';

  @override
  String get debugClockFaked => 'Faked';

  @override
  String get debugPickDate => 'Date';

  @override
  String get debugPickTime => 'Time';

  @override
  String get debugReset => 'Reset';

  @override
  String get debugPalette => 'Moment palette';

  @override
  String get debugPaletteAuto => 'Auto';

  @override
  String get debugDirection => 'Layout direction';

  @override
  String get debugBuild => 'Build';

  @override
  String get waqtMorning => 'সকাল';

  @override
  String nextIn(String prayer, String time) {
    return '$prayer $time পরে';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year হিজরি';
  }

  @override
  String get hijriMonth1 => 'মুহাররম';

  @override
  String get hijriMonth2 => 'সফর';

  @override
  String get hijriMonth3 => 'রবিউল আউয়াল';

  @override
  String get hijriMonth4 => 'রবিউস সানি';

  @override
  String get hijriMonth5 => 'জমাদিউল আউয়াল';

  @override
  String get hijriMonth6 => 'জমাদিউস সানি';

  @override
  String get hijriMonth7 => 'রজব';

  @override
  String get hijriMonth8 => 'শাবান';

  @override
  String get hijriMonth9 => 'রমজান';

  @override
  String get hijriMonth10 => 'শাওয়াল';

  @override
  String get hijriMonth11 => 'জিলকদ';

  @override
  String get hijriMonth12 => 'জিলহজ';

  @override
  String get locationUseGps => 'আমার অবস্থান ব্যবহার করুন';

  @override
  String get locationChooseCity => 'শহর বেছে নিন';

  @override
  String get locationLocating => 'অবস্থান খোঁজা হচ্ছে…';

  @override
  String get gpsServiceOff => 'এই ফোনে লোকেশন বন্ধ। চালু করুন, অথবা একটি শহর বেছে নিন।';

  @override
  String get gpsDenied => 'লোকেশনের অনুমতি দেওয়া হয়নি। আপনি একটি শহর বেছে নিতে পারেন।';

  @override
  String get gpsDeniedForever => 'লোকেশনের অনুমতি বন্ধ করা আছে। সেটিংসে অনুমতি দিন, অথবা একটি শহর বেছে নিন।';

  @override
  String get gpsTimeout => 'অবস্থান পাওয়া যায়নি। আবার চেষ্টা করুন, অথবা একটি শহর বেছে নিন।';

  @override
  String get openSettings => 'সেটিংস খুলুন';

  @override
  String get settingsLocation => 'অবস্থান';

  @override
  String get settingsNotSet => 'ঠিক করা হয়নি';

  @override
  String get settingsUseGps => 'বর্তমান অবস্থান ব্যবহার করুন';

  @override
  String get settingsGpsSource => 'জিপিএস থেকে';

  @override
  String get settingsPrayerTimes => 'নামাজের সময়';

  @override
  String get settingsMethod => 'হিসাবের পদ্ধতি';

  @override
  String get settingsRegionalDefault => 'আপনার অঞ্চলের ডিফল্ট';

  @override
  String get settingsAsr => 'আসরের সময়';

  @override
  String get asrStandard => 'জুমহুর';

  @override
  String get asrStandardHint => 'শাফেয়ি, মালিকি, হাম্বলি: ছায়া বস্তুর সমান';

  @override
  String get asrHanafi => 'হানাফি';

  @override
  String get asrHanafiHint => 'ছায়া বস্তুর দ্বিগুণ';

  @override
  String get settingsHighLat => 'উচ্চ অক্ষাংশের নিয়ম';

  @override
  String get highLatAuto => 'অটো';

  @override
  String get highLatAutoHint => '৪৮°-এর ওপরে রাতের সপ্তমাংশ, নিচে মধ্যরাত';

  @override
  String get highLatMiddle => 'মধ্যরাত';

  @override
  String get highLatSeventh => 'রাতের সপ্তমাংশ';

  @override
  String get highLatTwilight => 'গোধূলির কোণ';

  @override
  String get settingsCalendar => 'ক্যালেন্ডার';

  @override
  String get settingsHijriAdjust => 'হিজরি তারিখ অ্যাডজাস্ট';

  @override
  String get hijriAdjustHint => 'আপনার এলাকার চাঁদ দেখার সাথে মেলাতে';

  @override
  String get hijriOffsetNone => 'নেই';

  @override
  String hijriOffsetDays(String value) {
    return '$value দিন';
  }

  @override
  String get settingsAttribution => 'শহরের তথ্য © GeoNames, CC BY 4.0। নামাজের সময় ডিভাইসেই হিসাব হয়।';

  @override
  String get citySearchHint => 'শহর খুঁজুন';

  @override
  String cityNoResults(String query) {
    return '“$query” এর সাথে কোনো শহর মেলেনি';
  }

  @override
  String get methodMwl => 'মুসলিম ওয়ার্ল্ড লীগ';

  @override
  String get methodIsna => 'ISNA, উত্তর আমেরিকা';

  @override
  String get methodEgypt => 'মিশরীয় জরিপ কর্তৃপক্ষ';

  @override
  String get methodKarachi => 'ইসলামি বিজ্ঞান বিশ্ববিদ্যালয়, করাচি';

  @override
  String get methodUmmAlQura => 'উম্মুল কুরা, মক্কা';

  @override
  String get methodDubai => 'দুবাই';

  @override
  String get methodQatar => 'কাতার';

  @override
  String get methodKuwait => 'কুয়েত';

  @override
  String get methodSingapore => 'সিঙ্গাপুর, মালয়েশিয়া, ইন্দোনেশিয়া';

  @override
  String get methodTurkey => 'দিয়ানেত, তুরস্ক';

  @override
  String get methodTehran => 'ভূপদার্থবিদ্যা ইনস্টিটিউট, তেহরান';

  @override
  String get methodMoonsighting => 'চাঁদ দেখা কমিটি';

  @override
  String get timesEstimated => 'আনুমানিক। আজ এখানে সূর্য স্বাভাবিকভাবে ওঠে বা ডোবে না, তাই সময় ৬৫° অক্ষাংশ অনুযায়ী।';

  @override
  String get momentLastThird => 'রাতের শেষ তৃতীয়াংশ';

  @override
  String get momentFridayLastHour => 'জুমার দিনের শেষ মুহূর্ত';

  @override
  String momentAdhanIqamah(String prayer) {
    return '$prayer-এর ইকামতের আগে';
  }

  @override
  String momentAfterSalah(String prayer) {
    return '$prayer-এর পরে';
  }

  @override
  String get momentRestrictedSunrise => 'সূর্যোদয়ের সময়';

  @override
  String get momentRestrictedZawal => 'সূর্য মধ্যগগনে';

  @override
  String get momentRestrictedSunset => 'সূর্যাস্তের সময়';

  @override
  String get momentDuha => 'চাশত';

  @override
  String get momentMorningAdhkar => 'সকালের জিকির';

  @override
  String get momentEveningAdhkar => 'সন্ধ্যার জিকির';

  @override
  String get kindRestricted => 'নফল নামাজের নিষিদ্ধ সময়';

  @override
  String get rightNow => 'এখন';

  @override
  String until(String time) {
    return '$time পর্যন্ত';
  }

  @override
  String get comingUp => 'সামনে';

  @override
  String startsAt(String time) {
    return '$time-এ';
  }

  @override
  String startsIn(String time) {
    return '$time পরে';
  }

  @override
  String get timelineNow => 'এখন';

  @override
  String get debugJump => 'Jump to moment';

  @override
  String get statusDraft => 'খসড়া';

  @override
  String get statusChecked => 'যাচাইকৃত';

  @override
  String get draftNotice => 'যাচাই না করা খসড়া, শুধু ডেভেলপমেন্ট সংস্করণে দেখা যায়';

  @override
  String get collectionQuran => 'কুরআন';

  @override
  String get collectionBukhari => 'বুখারি';

  @override
  String get collectionMuslim => 'মুসলিম';

  @override
  String get collectionAbudawud => 'আবু দাউদ';

  @override
  String get collectionTirmidhi => 'তিরমিজি';

  @override
  String get collectionNasai => 'নাসায়ি';

  @override
  String get collectionIbnmajah => 'ইবনে মাজাহ';

  @override
  String get collectionMalik => 'Muwatta Malik';

  @override
  String get collectionAhmad => 'Ahmad';

  @override
  String get collectionDarimi => 'Darimi';

  @override
  String get collectionAdab => 'al-Adab al-Mufrad';

  @override
  String get collectionHakim => 'al-Hakim';

  @override
  String get collectionIbnhibban => 'Ibn Hibban';

  @override
  String get collectionBayhaqi => 'Bayhaqi';

  @override
  String get collectionNasaiKubra => 'al-Sunan al-Kubra';

  @override
  String get sheetSource => 'সূত্র';

  @override
  String get sheetNarrator => 'বর্ণনাকারী';

  @override
  String get sheetGrade => 'মান';

  @override
  String get sheetGradedBy => 'মান নির্ধারণকারী';

  @override
  String get sheetTranslation => 'অনুবাদ';

  @override
  String get sheetReview => 'যাচাই';

  @override
  String sheetOpen(String host) {
    return '$host-এ খুলুন';
  }

  @override
  String get sheetTextPending => 'এই সূত্রটি মূল উৎসের সাথে যাচাই হলে লেখাটি এখানে দেখা যাবে।';

  @override
  String get statusApproved => 'আলেম কর্তৃক অনুমোদিত';

  @override
  String get gradeSahih => 'সহিহ';

  @override
  String get gradeHasan => 'হাসান';

  @override
  String reviewCheckedBy(String name) {
    return 'যাচাই করেছেন $name';
  }

  @override
  String reviewApprovedBy(String name) {
    return 'অনুমোদন করেছেন $name';
  }

  @override
  String checklistProgress(String done, String total) {
    return '$totalটির মধ্যে $doneটি';
  }

  @override
  String get checklistTitleBedtime => 'ঘুমানোর আগে';

  @override
  String get checklistTitleJumuah => 'জুমা';

  @override
  String get momentJumuah => 'জুমা';

  @override
  String get librarySearch => 'দোয়া ও সূত্র খুঁজুন';

  @override
  String libraryNoMatch(String query) {
    return '“$query” এর জন্য কিছু পাওয়া যায়নি';
  }

  @override
  String libraryCount(String count) {
    return '$countটি';
  }

  @override
  String get libraryOther => 'অন্যান্য';

  @override
  String get momentLastThirdShort => 'শেষ তৃতীয়াংশ';

  @override
  String reminderBody(String time, String place) {
    return '$time · $place';
  }

  @override
  String get widgetEmptyBody => 'অবস্থান ঠিক করতে Waqt খুলুন';

  @override
  String get notifTitle => 'রিমাইন্ডার';

  @override
  String get notifHint => 'আরাফা, আশুরা, জুমা, রমজান ও আরও';

  @override
  String get notifPermission => 'নোটিফিকেশন';

  @override
  String get notifAllowed => 'অনুমতি আছে';

  @override
  String get notifAllow => 'অনুমতি দিন';

  @override
  String get notifExact => 'ঠিক সময়ে';

  @override
  String get notifExactHint => 'নামাজের রিমাইন্ডার যেন ঠিক মিনিটেই আসে';

  @override
  String get notifBattery => 'ব্যাটারি অপ্টিমাইজেশন';

  @override
  String get notifBatteryOk => 'সীমাবদ্ধ নয়';

  @override
  String get notifBatteryFix => 'সেটিংস খুলুন';

  @override
  String get notifBatteryHint => 'কিছু ফোন ব্যাকগ্রাউন্ডে রিমাইন্ডার বন্ধ করে দেয়। Waqt-কে সীমাবদ্ধ নয় হিসেবে রাখুন।';

  @override
  String notifBatteryHintOem(String maker) {
    return '$maker ফোন প্রায়ই ব্যাকগ্রাউন্ডে রিমাইন্ডার বন্ধ করে দেয়। Waqt-কে সীমাবদ্ধ নয় হিসেবে রাখুন।';
  }

  @override
  String get notifPrayers => 'নামাজের সময়';

  @override
  String get notifMoments => 'মুহূর্ত';

  @override
  String get notifSound => 'শব্দ';

  @override
  String get notifSoundHint => 'বন্ধ থাকলে সব রিমাইন্ডার নীরব থাকবে';

  @override
  String notifScheduled(String count, String date) {
    return '$date পর্যন্ত $countটি রিমাইন্ডার নির্ধারিত';
  }

  @override
  String get notifNone => 'কোনো রিমাইন্ডার নির্ধারিত নেই';

  @override
  String get notifStatus => 'অবস্থা';

  @override
  String get setupCardTitle => 'ওয়াক্তকে মনে করিয়ে দিতে দিন';

  @override
  String get setupCardBody => 'আরাফা, আশুরা বা ঈদের আগের রাতে, আর প্রতি জুমায়: কী করবেন, আর কেন।';

  @override
  String get setupCardAction => 'চালু করুন';

  @override
  String get setupCardDismiss => 'এখন না';

  @override
  String get momentLaylatAlQadr => 'শেষ দশকের একটি বেজোড় রাত';

  @override
  String get momentSuhoor => 'সাহরি';

  @override
  String get momentIftar => 'ইফতার';

  @override
  String get occEidAlFitr => 'ঈদুল ফিতর';

  @override
  String get occEidAlAdha => 'ঈদুল আজহা';

  @override
  String get occArafah => 'আরাফার দিন';

  @override
  String get occTashreeq => 'আইয়ামে তাশরিক';

  @override
  String get occAshura => 'আশুরা';

  @override
  String get occTasua => 'তাসুআ';

  @override
  String get occLastTen => 'শেষ দশ রাত';

  @override
  String occRamadan(String day) {
    return 'রমজান $day';
  }

  @override
  String get occFirstTen => 'জিলহজের প্রথম দশক';

  @override
  String get occBid => 'আইয়ামে বীজ';

  @override
  String get occMonday => 'সোমবারের রোজা';

  @override
  String get occThursday => 'বৃহস্পতিবারের রোজা';

  @override
  String get counterTitle => 'তাসবিহ';

  @override
  String get counterTap => 'গুনতে যেকোনো জায়গায় ট্যাপ করুন';

  @override
  String get counterReset => 'রিসেট';

  @override
  String counterRound(String n) {
    return 'রাউন্ড $n';
  }

  @override
  String get counterTarget => 'প্রতি রাউন্ডে কতবার';

  @override
  String get counterOpen => 'তাসবিহ কাউন্টার';

  @override
  String get reportContent => 'এই লেখায় ভুল জানান';

  @override
  String get reportProblem => 'সমস্যা জানান';

  @override
  String get reportProblemHint => 'একটি ইমেইল খসড়া খোলে। পাঠানোর আগে আপনি সব দেখতে পাবেন।';

  @override
  String get privacyTitle => 'গোপনীয়তা';

  @override
  String get privacyBody => 'সবকিছু এই ফোনেই হিসাব হয়। Waqt-এ কোনো অ্যাকাউন্ট, বিজ্ঞাপন বা অ্যানালিটিক্স নেই।';

  @override
  String placeTime(String city) {
    return '$city-এর সময়';
  }

  @override
  String get testModeUnlocked => 'Test mode is on. Find it at the bottom of Settings.';

  @override
  String get debugJumpDay => 'Jump to a day';

  @override
  String get debugNextFriday => 'Next Friday';

  @override
  String get debugContent => 'Content';

  @override
  String get debugShowUnchecked => 'Show unchecked content';

  @override
  String get debugShowUncheckedHint => 'On this phone only. Unchecked items are marked as drafts.';

  @override
  String get debugLock => 'Turn off test mode';

  @override
  String get checkerTitle => 'Check references';

  @override
  String get checkerHint => 'Open each reference at its source and confirm it';

  @override
  String checkerProgress(int done, int total) {
    return '$done of $total checked';
  }

  @override
  String get checkerOpen => 'Open source';

  @override
  String get checkerCorrect => 'Correct';

  @override
  String get checkerWrong => 'Wrong';

  @override
  String get checkerWrongHint => 'What is wrong, and the correct reference if you know it';

  @override
  String get checkerSend => 'Email results';

  @override
  String windowLeft(String time) {
    return '$time বাকি';
  }

  @override
  String windowPreferred(String time) {
    return '$time-এর আগে উত্তম';
  }

  @override
  String durHm(String h, String m) {
    return '$h ঘ $m মি';
  }

  @override
  String durM(String m) {
    return '$m মি';
  }

  @override
  String get counterChoose => 'জিকির বদলান';

  @override
  String counterStep(String n, String total) {
    return 'ধাপ $n/$total';
  }

  @override
  String get counterFree => 'ফ্রি কাউন্ট';

  @override
  String get counterFreeHint => 'যেকোনো কিছু গুনুন, নিজের সংখ্যায়';

  @override
  String get counterAfterSalah => 'নামাজের পর: ৩৩ · ৩৩ · ৩৪';

  @override
  String get counterHaptics => 'প্রতি গণনায় ভাইব্রেশন';

  @override
  String get counterAfterSalahName => 'নামাজের পর';

  @override
  String get librarySearchAll => 'হাদিস ও দোয়া খুঁজুন';

  @override
  String get scopeDuas => 'দোয়া';

  @override
  String get scopeHadith => 'হাদিস';

  @override
  String get librarySituations => 'সব পরিস্থিতি';

  @override
  String get libraryForNow => 'এখন';

  @override
  String duaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$countটি দোয়া', one: '১টি দোয়া');
    return '$_temp0';
  }

  @override
  String get libraryPreparing => 'হাদিস খোঁজার প্রস্তুতি চলছে। এটি একবারই হয়।';

  @override
  String get libraryRefine => 'প্রথম ৬০টি দেখানো হচ্ছে। সংকুচিত করতে শব্দ যোগ করুন।';

  @override
  String get sourceHisn =>
      'Hisn al-Muslim by Sa\'id bin Ali bin Wahf al-Qahtani. Text, transliteration and translation as published on sunnah.com, via open-hadith-data.';

  @override
  String get sourceHadith =>
      'Arabic and English as published on sunnah.com, via open-hadith-data. Grades as given by the source.';

  @override
  String hisnNumber(String n) {
    return 'হিসনুল মুসলিম $n';
  }

  @override
  String get copyText => 'কপি';

  @override
  String get copied => 'কপি হয়েছে';

  @override
  String get openSource => 'উৎস খুলুন';

  @override
  String get readingTitle => 'ফন্ট সাইজ';

  @override
  String get readingHint => 'আরবি, উচ্চারণ ও অর্থ, আলাদাভাবে';

  @override
  String get readingArabic => 'আরবি';

  @override
  String get readingTransliteration => 'উচ্চারণ';

  @override
  String get readingMeaning => 'অর্থ';

  @override
  String stripLeft(String time, String prayer) {
    return '$prayer পর্যন্ত $time';
  }

  @override
  String get dayGuideToday => 'আজকের সুন্নাহ';

  @override
  String fastToday(String day) {
    return 'আজ সুন্নাত রোজা · $day';
  }

  @override
  String fastTomorrow(String day) {
    return 'আগামীকাল রোজা · $day';
  }

  @override
  String get calendarTitle => 'ক্যালেন্ডার';

  @override
  String get calendarLegendGuide => 'নির্দেশনা আছে';

  @override
  String get calendarLegendFast => 'সুন্নাত রোজা';

  @override
  String get calendarNote =>
      'তারিখ উম্মুল কুরা ও আপনার হিজরি সমন্বয় অনুযায়ী। শাবান, রমজান ও জিলকদের ২৯ তারিখে হোম আপনাকে চাঁদ দেখা গেছে কি না জিজ্ঞেস করে।';

  @override
  String sightingTitle(String month) {
    return 'আপনার এলাকায় কি $month-এর চাঁদ দেখা গেছে?';
  }

  @override
  String get sightingBody => 'আপনার উত্তর ক্যালেন্ডার সরিয়ে দেয় যাতে রমজান, ঈদ ও আরাফা আপনার সমাজের দিনে পড়ে।';

  @override
  String sightingSeen(String month) {
    return 'দেখা গেছে: $month শুরু';
  }

  @override
  String get sightingNotSeen => 'দেখা যায়নি: ৩০ দিন';

  @override
  String get sightingUnsure => 'নিশ্চিত নই';

  @override
  String get ramadanSuhoor => 'সাহরি শেষ';

  @override
  String get ramadanIftar => 'ইফতার';

  @override
  String ramadanIn(String time) {
    return '$time পরে';
  }

  @override
  String get ramadanDone => 'শেষ';

  @override
  String announceTitle(String month) {
    return 'আজ রাতে $month নির্ধারণ';
  }

  @override
  String announceBegins(String month, String authority) {
    return '$authority অনুযায়ী আগামীকাল $month শুরু।';
  }

  @override
  String announceThirty(String month, String authority) {
    return '$authority অনুযায়ী $month ৩০ দিন পূর্ণ করবে: আগামীকাল ৩০ তারিখ।';
  }

  @override
  String get announceOffline => 'অফলাইন: সর্বশেষ ডাউনলোড করা তারিখ দেখানো হচ্ছে। সংযোগ পেলে আবার দেখা হবে।';

  @override
  String announceChecking(String time) {
    return 'আজ রাতে প্রতি ৩০ মিনিটে ঘোষণা দেখা হয়। সর্বশেষ $time।';
  }

  @override
  String get authoritySaudi => 'সৌদি সুপ্রিম জুডিশিয়াল কাউন্সিল';

  @override
  String get authorityDiyanet => 'দিয়ানেত (তুরস্ক)';

  @override
  String get authorityLocal => 'স্থানীয় চাঁদ দেখা';

  @override
  String get authoritySaudiHint => 'ঘোষিত চাঁদ দেখা, অনলাইনে হালনাগাদ';

  @override
  String get authorityDiyanetHint => 'তুরস্কের সরকারি ক্যালেন্ডার, অনলাইনে হালনাগাদ';

  @override
  String get authorityLocalHint => 'উম্মুল কুরা; ২৯ তারিখে আপনি জানান চাঁদ দেখা গেছে কি না';

  @override
  String calendarSourceLine(String authority, String time) {
    return '$authority · $time-এ দেখা';
  }

  @override
  String get calendarSourceLocal =>
      'উম্মুল কুরা ও আপনার সমন্বয়। শাবান, রমজান ও জিলকদের ২৯ তারিখে হোম চাঁদ দেখার কথা জিজ্ঞেস করে।';

  @override
  String announceUnknown(String month) {
    return 'ঘোষণা এখনও ওয়াক্তে পৌঁছায়নি। আজ রাতে চাঁদ দেখা গেলে আগামীকাল $month শুরু; না দেখা গেলে এই মাস ৩০ দিন পূর্ণ করবে।';
  }

  @override
  String get adjustTitle => 'সময় অ্যাডজাস্ট';

  @override
  String get adjustRowHint => 'স্থানীয় সময়সূচি বা মসজিদের সাথে মেলান';

  @override
  String get adjustNone => 'নেই';

  @override
  String adjustSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$countটি সময়', one: '১টি সময়');
    return '$_temp0';
  }

  @override
  String get adjustHint =>
      'সময়গুলো আপনার সঠিক অবস্থান অনুযায়ী হিসাব করা হয়। আপনার স্থানীয় সময়সূচি (যেমন ইসলামিক ফাউন্ডেশন বা মসজিদ) এক-দুই মিনিট আলাদা হলে এখানে মেলান।';

  @override
  String get adjustNote =>
      'সাহরি ফজরে শেষ এবং ইফতার মাগরিবে, তাই এগুলো সমন্বয় করলে সাহরি ও ইফতারও বদলায়। রিমাইন্ডার ও উইজেটও অনুসরণ করে।';

  @override
  String get adjustEarlier => '১ মিনিট আগে';

  @override
  String get adjustLater => '১ মিনিট পরে';

  @override
  String get momentTaraweeh => 'তারাবিহ';

  @override
  String get showLess => 'কম দেখান';

  @override
  String showAll(int count) {
    return 'সব দেখান ($count)';
  }

  @override
  String get hadithUnavailable => 'হাদিস খোঁজা এখানে নেই। অ্যান্ড্রয়েড অ্যাপে কাজ করে।';

  @override
  String get hadithLibraryTitle => 'হাদিস লাইব্রেরি';

  @override
  String get hadithLibraryBody =>
      'আপনার ভাষায় HadeethEnc বিশ্বকোষ: আরবি, মান ও ব্যাখ্যাসহ সহিহ হাদিস, অফলাইনে খোঁজা যায়। একবার ডাউনলোড করলেই হবে।';

  @override
  String hadithLibraryDownload(String mb) {
    return 'ডাউনলোড ($mb MB)';
  }

  @override
  String hadithLibraryProgress(int percent) {
    return 'ডাউনলোড হচ্ছে… $percent%';
  }

  @override
  String get hadithLibraryFailed => 'ডাউনলোড শেষ হয়নি। সংযোগ দেখুন।';

  @override
  String get hadithLibraryRetry => 'আবার চেষ্টা করুন';

  @override
  String get hadithLibraryNote => 'HadeethEnc.com থেকে, হুবহু। হোম, চেকলিস্ট ও তাসবিহ এটি ছাড়াই চলে।';

  @override
  String counterToday(String count) {
    return 'আজ $count';
  }

  @override
  String get counterTodayTitle => 'আজ পড়েছেন';

  @override
  String get counterTodayAll => 'সব জিকির';

  @override
  String get counterResetRound => 'এই রাউন্ড আবার শুরু';

  @override
  String get debugScenarios => 'Scenarios';

  @override
  String get debugState => 'What the app sees';

  @override
  String get debugData => 'Data';

  @override
  String get debugRefreshCalendar => 'Check the calendar now';

  @override
  String get debugClearTicks => 'Clear today\'s ticks';

  @override
  String get debugClearCounter => 'Clear the counter';

  @override
  String get debugClearSightings => 'Forget moon-sighting answers';

  @override
  String get debugRemoveHadith => 'Remove the hadith library';

  @override
  String get debugDone => 'Done';

  @override
  String get debugScEveRamadan => '29 Shaban evening';

  @override
  String get debugScSuhoor => 'Ramadan suhoor';

  @override
  String get debugScIftar => 'Ramadan iftar';

  @override
  String get debugScTaraweeh => 'Taraweeh';

  @override
  String get debugScQadr => '27th night, last third';

  @override
  String get debugScEveEid => '29 Ramadan evening';

  @override
  String get debugScEid => 'Eid al-Fitr morning';

  @override
  String get debugScArafah => 'Arafah';

  @override
  String get debugScAshura => 'Ashura';

  @override
  String get counterAddOwn => 'নিজের জিকির যোগ করুন';

  @override
  String get counterOwnName => 'কী পড়বেন';

  @override
  String get counterOwnArabic => 'আরবি (ঐচ্ছিক)';

  @override
  String get counterOwnTarget => 'কতবার';

  @override
  String get counterSave => 'সেভ করুন';

  @override
  String get counterRemove => 'মুছুন';

  @override
  String get counterSectionReward => 'ফজিলতপূর্ণ জিকির';

  @override
  String get counterSectionYours => 'আপনার জিকির';

  @override
  String get sheetExplanation => 'ব্যাখ্যা';

  @override
  String get sheetEnglishOriginal => 'ইংরেজি (sunnah.com)';

  @override
  String sourceHadeethEnc(String date) {
    return 'অনুবাদ ও ব্যাখ্যা: HadeethEnc.com, হুবহু ($date তারিখে নেওয়া)।';
  }

  @override
  String get openHadeethEnc => 'HadeethEnc';

  @override
  String heNotTranslated(String language) {
    return 'HadeethEnc এখনও এই হাদিসের $language অনুবাদ প্রকাশ করেনি, তাই আরবি দেখানো হলো।';
  }

  @override
  String get libraryAllTopics => 'সব বিষয়';

  @override
  String get qiblaTitle => 'কিবলা';

  @override
  String qiblaFrom(String city) {
    return '$city থেকে';
  }

  @override
  String get qiblaFacing => 'আপনি কিবলামুখী';

  @override
  String get qiblaTurnRight => 'ডানে ঘুরুন';

  @override
  String get qiblaTurnLeft => 'বাঁয়ে ঘুরুন';

  @override
  String get qiblaDirection => 'দিক';

  @override
  String qiblaBearing(String deg) {
    return 'উত্তর থেকে $deg°';
  }

  @override
  String get qiblaDistance => 'কাবা পর্যন্ত দূরত্ব';

  @override
  String qiblaKm(String km) {
    return '$km কিমি';
  }

  @override
  String get qiblaHoldFlat => 'ফোনটি সমতলে রাখুন';

  @override
  String get qiblaCalibrate => 'দিক সরে গেলে ফোনটি ইংরেজি 8-এর মতো করে ঘোরান, ধাতু ও চুম্বক থেকে দূরে।';

  @override
  String qiblaNoCompass(String deg) {
    return 'এই ডিভাইসে কম্পাস নেই। কোনো চিহ্ন বা সূর্য দেখে উত্তর থেকে $deg° দিকে মুখ করুন।';
  }

  @override
  String get qiblaNoPlace => 'কিবলা খুঁজতে একটি শহর বেছে নিন।';

  @override
  String get qiblaNorthShort => 'উ';

  @override
  String get footerHandcrafted => 'যত্ন নিয়ে বানিয়েছেন';

  @override
  String get footerSignatureLabel => 'অর্ণব আদির স্বাক্ষর';

  @override
  String footerVersion(String version) {
    return 'ওয়াক্ত · বেটা $version';
  }

  @override
  String get footerTagline => 'অফলাইন · বিজ্ঞাপন নেই · ট্র্যাকিং নেই';

  @override
  String get footerDuaRequest => 'আপনার দোয়ায় আমাকে মনে রাখবেন।';

  @override
  String remTitle(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'ramadan': '🌙 আজ রাত থেকে রমজান',
      'dhulHijjah': '🕋 বছরের শ্রেষ্ঠ দশ দিন শুরু',
      'arafah': '🤲 আগামীকাল আরাফার দিন',
      'eidFitr': '🎉 আগামীকাল ঈদুল ফিতর',
      'eidAdha': '🐑 আগামীকাল ঈদুল আযহা',
      'tasua': '🗓️ আগামীকাল তাসুআর রোজা',
      'ashura': '🌊 আগামীকাল আশুরা',
      'whiteDays': '🌕 আগামীকাল থেকে আইয়ামে বীয',
      'monday': '🗓️ আগামীকাল সোমবারের রোজা',
      'thursday': '🗓️ আগামীকাল বৃহস্পতিবারের রোজা',
      'jumuah': '🕌 জুমা মুবারক',
      'fridayLastHour': '🤲 জুমার দোয়া কবুলের সময়',
      'suhoor': '🌙 সাহরির সময়',
      'iftar': '🌅 ইফতারের সময়',
      'laylatAlQadr': '✨ আজ হয়তো লাইলাতুল কদর',
      'morningAdhkar': '☀️ সকালের জিকির',
      'eveningAdhkar': '🌇 সন্ধ্যার জিকির',
      'lastThird': '🌌 রাতের শেষ তৃতীয়াংশ',
      'bedtime': '😴 ঘুমানোর আগে',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remBody(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'ramadan': 'আজ রাতে তারাবিহ, ফজরের আগে সাহরি। যে ঈমান ও সওয়াবের আশায় রমজানের রোজা রাখে, তার আগের গুনাহ মাফ হয় (বুখারি)।',
      'dhulHijjah': 'এই দশ দিনের চেয়ে আল্লাহর কাছে নেক আমল প্রিয় হয় এমন কোনো দিন নেই (বুখারি)। তাকবির, রোজা, দান।',
      'arafah': 'এর রোজা আগের ও পরের বছরের গুনাহ মুছে দেয় (মুসলিম)। আজ রাতেই নিয়ত করুন।',
      'eidFitr': 'ঈদের নামাজের আগে সদাকাতুল ফিতর দিন, আর আজ রাত থেকে তাকবির বলুন।',
      'eidAdha': 'তাকবির বলুন, সকালে ঈদের নামাজ পড়ুন, তারপর কুরবানি দিন।',
      'tasua': 'নবী ﷺ আশুরার সঙ্গে নবম তারিখেও রোজা রাখার ইচ্ছা করেছিলেন (মুসলিম)। পরের দিন আশুরা।',
      'ashura': 'আশুরার রোজা আগের বছরের গুনাহ মুছে দেয় (মুসলিম)। আজ রাতেই নিয়ত করুন।',
      'whiteDays': '১৩, ১৪ ও ১৫ তারিখে রোজা: প্রতি মাসে তিনটি রোজা সারা বছর রোজা রাখার মতো (বুখারি)।',
      'monday': 'সোম ও বৃহস্পতিবার আমল পেশ করা হয়, আর নবী ﷺ রোজা অবস্থায় তা পেশ হওয়া পছন্দ করতেন (তিরমিজি)।',
      'thursday': 'সোম ও বৃহস্পতিবার আমল পেশ করা হয়, আর নবী ﷺ রোজা অবস্থায় তা পেশ হওয়া পছন্দ করতেন (তিরমিজি)।',
      'jumuah': 'গোসল করুন, আগে আগে যান, সূরা কাহফ পড়ুন এবং আজ নবী ﷺ-এর ওপর বেশি বেশি দরুদ পড়ুন।',
      'fridayLastHour': 'জুমার দিনে এমন একটি সময় আছে যখন সব দোয়া কবুল হয় (বুখারি)। মাগরিবের আগে এখনই খুঁজুন।',
      'suhoor': 'সাহরি খাও, কারণ সাহরিতে বরকত আছে (বুখারি)। ফজর কাছেই।',
      'iftar': 'মানুষ ততদিন কল্যাণে থাকবে যতদিন তারা দ্রুত ইফতার করবে (বুখারি)। ইফতারের সময় দোয়া করুন।',
      'laylatAlQadr':
          'হাজার মাসের চেয়ে উত্তম। নামাজ পড়ুন আর বলুন: আল্লাহুম্মা ইন্নাকা আফুউন তুহিব্বুল আফওয়া ফা’ফু আন্নি।',
      'morningAdhkar': 'কয়েক মিনিটের জিকির, যাতে দিন শুরু হয় আল্লাহর হেফাজতে।',
      'eveningAdhkar': 'মাগরিবের আগে সন্ধ্যার জিকির। পড়তে ট্যাপ করুন।',
      'lastThird': 'আমাদের রব দুনিয়ার আকাশে নেমে আসেন এবং বলেন: কে আমাকে ডাকে, আমি তার ডাকে সাড়া দেব? (বুখারি)',
      'bedtime': 'আয়াতুল কুরসি, সূরা বাকারার শেষ দুই আয়াত আর ঘুমের দোয়া। দুই মিনিট।',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'ramadan': 'রমজানের শুরু',
      'dhulHijjah': 'জিলহজ ও আরাফা',
      'eid': 'ঈদ',
      'ashura': 'তাসুআ ও আশুরা',
      'whiteDays': 'আইয়ামে বীয',
      'monThu': 'সোম ও বৃহস্পতিবারের রোজা',
      'jumuah': 'জুমার সকাল',
      'fridayLastHour': 'জুমার বিশেষ সময়',
      'suhoor': 'সাহরি',
      'iftar': 'ইফতার',
      'laylatAlQadr': 'শেষ দশকের বেজোড় রাত',
      'morningAdhkar': 'সকালের জিকির',
      'eveningAdhkar': 'সন্ধ্যার জিকির',
      'lastThird': 'রাতের শেষ তৃতীয়াংশ',
      'bedtime': 'ঘুমানোর আগে',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remWhen(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'ramadan': 'যে রাতে রমজান শুরু হয়',
      'dhulHijjah': 'দশ দিন শুরু হলে, আর আরাফার আগের রাতে',
      'eid': 'প্রতি ঈদের আগের সন্ধ্যায়',
      'ashura': 'মুহাররমের ৯ ও ১০ তারিখের আগের সন্ধ্যায়',
      'whiteDays': 'প্রতি মাসে ১৩ তারিখের আগের সন্ধ্যায়',
      'monThu': 'রবি ও বুধবার সন্ধ্যায়',
      'jumuah': 'শুক্রবার সকালে',
      'fridayLastHour': 'শুক্রবার, মাগরিবের আগের শেষ ঘণ্টা',
      'suhoor': 'রমজানে প্রতিদিন ফজরের আগে',
      'iftar': 'রমজানে প্রতিদিন মাগরিবে',
      'laylatAlQadr': '২১, ২৩, ২৫, ২৭ ও ২৯ তারিখের রাত',
      'morningAdhkar': 'ফজরের পর',
      'eveningAdhkar': 'আসরের পর',
      'lastThird': 'শেষ তৃতীয়াংশ শুরু হলে',
      'bedtime': 'আপনার ঘুমের সময়',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get remHeroTitle => 'সবচেয়ে মূল্যবান মুহূর্তগুলো হাতছাড়া করবেন না';

  @override
  String get remHeroBody =>
      'ওয়াক্ত শুধু সবচেয়ে বেশি সওয়াবের সময়গুলোতে মনে করিয়ে দেয়: আরাফা, আশুরা, লাইলাতুল কদর, প্রতি জুমা। প্রতিটি রিমাইন্ডার বলে কী করবেন আর কেন, সূত্রসহ।';

  @override
  String get remTurnOn => 'রিমাইন্ডার চালু করুন';

  @override
  String get remComingUp => 'সামনের রিমাইন্ডার';

  @override
  String get remNothingSoon => 'আগামী এক মাসে কিছু নেই। নিচে আরও রিমাইন্ডার চালু করুন।';

  @override
  String get remPreview => 'দেখুন কেমন হবে';

  @override
  String get remTest => 'একটি পরীক্ষামূলক রিমাইন্ডার পাঠান';

  @override
  String get remTestSent => 'পাঠানো হয়েছে। নোটিফিকেশন দেখুন।';

  @override
  String get remNow => 'এখন';

  @override
  String get remGroupSpecial => 'বিশেষ দিন';

  @override
  String get remGroupFriday => 'প্রতি জুমা';

  @override
  String get remGroupRamadan => 'রমজানে';

  @override
  String get remGroupDaily => 'প্রতিদিন';

  @override
  String get remDailyNote => 'শুরুতে বন্ধ থাকে, যাতে সবচেয়ে জরুরি রিমাইন্ডারগুলো আলাদা করে চোখে পড়ে।';

  @override
  String get qiblaFromLabel => 'কিবলা, যেখান থেকে';

  @override
  String get qiblaToLeft => 'আপনার বাঁয়ে';

  @override
  String get qiblaToRight => 'আপনার ডানে';

  @override
  String qiblaToMakkah(String km) {
    return 'মক্কা $km কিমি দূরে';
  }

  @override
  String get qiblaHint => 'ঘুরুন, যতক্ষণ না তীর ওপরে দেখায় আর স্ক্রিন উজ্জ্বল হয়।';

  @override
  String get deedOnTime => 'সময়মতো পড়েছি';

  @override
  String get deedJamaah => 'জামাতে';

  @override
  String get deedQada => 'কাজা আদায়';

  @override
  String get deedNotPrayed => 'চিহ্নিত নয়';

  @override
  String deedPrayedCount(String done) {
    return '৫ ওয়াক্তের $doneটি পড়েছি';
  }

  @override
  String get deedRingHint => 'নামাজ পড়ার পর \"এখন\" পাতায় টিক দিন। শুধু আপনিই দেখবেন।';

  @override
  String deedStreak(String days) {
    return 'টানা $days দিন পাঁচ ওয়াক্ত';
  }

  @override
  String get progressTitle => 'আপনার অগ্রগতি';

  @override
  String get progressThisWeek => 'এই সপ্তাহ';

  @override
  String get progressBestRun => 'পাঁচ ওয়াক্তের দীর্ঘতম ধারা';

  @override
  String get progressQada => 'চিহ্নহীন, কাজা (৩০ দিন)';

  @override
  String progressDays(String days) {
    return '$days দিন';
  }

  @override
  String get progressReflection =>
      '\"আল্লাহর কাছে সবচেয়ে প্রিয় আমল তা-ই, যা নিয়মিত করা হয়, যদিও তা অল্প হয়।\" (বুখারি, মুসলিম)';

  @override
  String progressOfPrayers(String total) {
    return '$total ওয়াক্তের মধ্যে';
  }

  @override
  String get progressOnTimeShort => 'সময়মতো';

  @override
  String get progressCurrentRun => 'টানা দিন';

  @override
  String get progressByPrayer => 'প্রতি ওয়াক্ত, গত ৩০ দিন';

  @override
  String progressHardest(String prayer) {
    return 'এখন $prayer সবচেয়ে বেশি যত্ন চায়।';
  }

  @override
  String get progressWeeks => 'গত ১২ সপ্তাহ';

  @override
  String get progressEmpty =>
      'নামাজ পড়ার পর \"এখন\" পাতায় সেটিতে চাপুন। আপনার দিনগুলো এখানে ভরে উঠবে, শুধু এই ফোনেই।';

  @override
  String get progressEditHint => 'যা পড়েছেন তা লিখতে কোনো দিনে চাপুন।';

  @override
  String durShortHm(String h, String m) {
    return '$hঘ $mমি';
  }

  @override
  String durShortM(String m) {
    return '$mমি';
  }

  @override
  String beadLeft(String time) {
    return '$time বাকি';
  }

  @override
  String beadIn(String time) {
    return '$time পরে';
  }

  @override
  String get beadEnded => 'শেষ';

  @override
  String get onbWelcomeTitle => 'প্রতিটি মুহূর্তের সঠিক দোয়া';

  @override
  String get onbWelcomeBody => 'সবই সুন্নাহ থেকে, সূত্রসহ।';

  @override
  String get onbWelcomeNote => 'ফ্রি। কোনো অ্যাকাউন্ট নেই, বিজ্ঞাপন নেই।';

  @override
  String get onbBegin => 'শুরু করুন';

  @override
  String get onbLanguageTitle => 'আপনার ভাষা বেছে নিন';

  @override
  String get onbLanguageBody => 'দোয়া সবসময় আরবিতেই থাকে।';

  @override
  String get onbPhoneLanguage => 'আপনার ফোনের ভাষা';

  @override
  String get onbContinue => 'এগিয়ে যান';

  @override
  String get onbLocationTitle => 'আপনি কোথা থেকে নামাজ পড়েন?';

  @override
  String get onbLocationBody => 'নামাজের সময় ও কিবলার জন্য। এটি এই ফোনেই থাকে।';

  @override
  String get onbCityInstead => 'বরং একটি শহর বেছে নিন';

  @override
  String get onbRemindersTitle => 'শুধু গুরুত্বপূর্ণ মুহূর্তগুলো';

  @override
  String get onbRemindersBody => 'আরাফা, আশুরা, ঈদ আর জুমা। কোনো বাড়তি শব্দ নয়।';

  @override
  String get onbRemindersOn => 'রিমাইন্ডার চালু করুন';

  @override
  String get onbLater => 'পরে';

  @override
  String onbStep(int n, int total) {
    return 'ধাপ $n / $total';
  }

  @override
  String get beadOnTime => 'সময়মতো';

  @override
  String get beadJamaah => 'জামাআত';

  @override
  String get beadLate => 'কাজা';

  @override
  String get comingUpTitle => 'আসছে';

  @override
  String comingIn(String time) {
    return '$time পর';
  }

  @override
  String get beadTapToMark => 'মার্ক';
}
