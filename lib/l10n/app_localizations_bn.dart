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
  String get settingsDeveloper => 'Developer';

  @override
  String get settingsDeveloperHint => 'Fake clock and moment palettes';

  @override
  String get settingsAbout => 'Waqt সম্পর্কে';

  @override
  String settingsVersion(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get debugTitle => 'Developer';

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
  String get highLatAuto => 'স্বয়ংক্রিয়';

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
  String get settingsHijriAdjust => 'হিজরি তারিখ সমন্বয়';

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
  String get notifHint => 'নামাজের সময় ও মুহূর্ত, আপনার পছন্দমতো';

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
  String get notifSoundHint => 'লাইসেন্সপ্রাপ্ত রেকর্ডিং যোগ হলে আজানের বিকল্প আসবে';

  @override
  String notifScheduled(String count, String date) {
    return '$date পর্যন্ত $countটি রিমাইন্ডার নির্ধারিত';
  }

  @override
  String get notifNone => 'কোনো রিমাইন্ডার নির্ধারিত নেই';

  @override
  String get notifStatus => 'অবস্থা';

  @override
  String get setupCardTitle => 'নরম রিমাইন্ডার';

  @override
  String get setupCardBody =>
      'প্রতি নামাজের সময় একটি শান্ত স্মরণ। কোনগুলো চান তা আপনিই বেছে নেবেন, আর কিছুই ফোনের বাইরে যায় না।';

  @override
  String get setupCardAction => 'সেট করুন';

  @override
  String get setupCardDismiss => 'এখন না';

  @override
  String get momentLaylatAlQadr => 'শেষ দশকের একটি বেজোড় রাত';

  @override
  String get momentSuhoor => 'সেহরি';

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
  String get counterTap => 'গুনতে যেকোনো জায়গায় ছুঁয়ে দিন';

  @override
  String get counterReset => 'আবার শুরু';

  @override
  String counterRound(String n) {
    return '$n নম্বর চক্র';
  }

  @override
  String get counterTarget => 'প্রতি চক্রে দানা';

  @override
  String get counterOpen => 'তাসবিহ খুলুন';

  @override
  String get reportContent => 'এই লেখায় ভুল জানান';

  @override
  String get reportProblem => 'সমস্যা জানান';

  @override
  String get reportProblemHint => 'GitHub-এ একটি পূরণ করা ফর্ম খোলে। পাঠানোর আগে আপনি সব দেখতে পাবেন।';

  @override
  String get privacyTitle => 'গোপনীয়তা';

  @override
  String get privacyBody => 'সবকিছু এই ফোনেই হিসাব হয়। Waqt-এ কোনো অ্যাকাউন্ট, বিজ্ঞাপন বা অ্যানালিটিক্স নেই।';

  @override
  String placeTime(String city) {
    return '$city-এর সময়';
  }
}
