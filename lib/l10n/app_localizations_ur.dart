// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appName => 'وقت';

  @override
  String get navNow => 'ابھی';

  @override
  String get navToday => 'آج';

  @override
  String get navDuas => 'دعائیں';

  @override
  String get navSettings => 'ترتیبات';

  @override
  String get prayerFajr => 'فجر';

  @override
  String get prayerSunrise => 'طلوعِ آفتاب';

  @override
  String get prayerDhuhr => 'ظہر';

  @override
  String get prayerAsr => 'عصر';

  @override
  String get prayerMaghrib => 'مغرب';

  @override
  String get prayerIsha => 'عشاء';

  @override
  String get momentNight => 'رات';

  @override
  String get momentBedtime => 'سونے کا وقت';

  @override
  String get timePending => '–';

  @override
  String get nowLocationTitle => 'آپ کہاں نماز پڑھتے ہیں؟';

  @override
  String get nowLocationBody =>
      'نماز کے اوقات آپ کے مقام سے آپ کے فون پر ہی حساب کیے جاتے ہیں۔ کچھ بھی آلے سے باہر نہیں جاتا۔';

  @override
  String get todayEmptyTitle => 'آپ کا دن، لمحہ بہ لمحہ';

  @override
  String get todayEmptyBody =>
      'نماز کے اوقات کا حساب ہوتے ہی فجر سے رات کے آخری تہائی حصے تک آج کا ہر وقت یہاں ترتیب سے آ جائے گا۔';

  @override
  String get duasEmptyTitle => 'صرف تصدیق شدہ ماخذ';

  @override
  String get duasEmptyBody =>
      'لائبریری تب کھلے گی جب ہر متن اپنے اصل ماخذ سے جانچا جائے اور کسی عالم کی منظوری مل جائے۔';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsLanguageSystem => 'آلے کی زبان';

  @override
  String get settingsDeveloper => 'Test mode';

  @override
  String get settingsDeveloperHint => 'Fake clock, day jumps and the reference checker';

  @override
  String get settingsAbout => 'وقت کے بارے میں';

  @override
  String settingsVersion(String version) {
    return 'ورژن $version';
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
  String get waqtMorning => 'چاشت';

  @override
  String nextIn(String prayer, String time) {
    return '$prayer میں $time';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year ہجری';
  }

  @override
  String get hijriMonth1 => 'محرم';

  @override
  String get hijriMonth2 => 'صفر';

  @override
  String get hijriMonth3 => 'ربیع الاول';

  @override
  String get hijriMonth4 => 'ربیع الثانی';

  @override
  String get hijriMonth5 => 'جمادی الاول';

  @override
  String get hijriMonth6 => 'جمادی الثانی';

  @override
  String get hijriMonth7 => 'رجب';

  @override
  String get hijriMonth8 => 'شعبان';

  @override
  String get hijriMonth9 => 'رمضان';

  @override
  String get hijriMonth10 => 'شوال';

  @override
  String get hijriMonth11 => 'ذوالقعدہ';

  @override
  String get hijriMonth12 => 'ذوالحجہ';

  @override
  String get locationUseGps => 'میرا مقام استعمال کریں';

  @override
  String get locationChooseCity => 'شہر منتخب کریں';

  @override
  String get locationLocating => 'مقام تلاش ہو رہا ہے…';

  @override
  String get gpsServiceOff => 'اس فون پر مقام بند ہے۔ اسے آن کریں یا شہر منتخب کریں۔';

  @override
  String get gpsDenied => 'مقام کی اجازت نہیں دی گئی۔ آپ شہر منتخب کر سکتے ہیں۔';

  @override
  String get gpsDeniedForever => 'مقام کی اجازت بند ہے۔ ترتیبات میں اجازت دیں یا شہر منتخب کریں۔';

  @override
  String get gpsTimeout => 'مقام نہیں ملا۔ دوبارہ کوشش کریں یا شہر منتخب کریں۔';

  @override
  String get openSettings => 'ترتیبات کھولیں';

  @override
  String get settingsLocation => 'مقام';

  @override
  String get settingsNotSet => 'مقرر نہیں';

  @override
  String get settingsUseGps => 'موجودہ مقام استعمال کریں';

  @override
  String get settingsGpsSource => 'جی پی ایس سے';

  @override
  String get settingsPrayerTimes => 'نماز کے اوقات';

  @override
  String get settingsMethod => 'حساب کا طریقہ';

  @override
  String get settingsRegionalDefault => 'آپ کے علاقے کا معیاری';

  @override
  String get settingsAsr => 'عصر کا وقت';

  @override
  String get asrStandard => 'جمہور';

  @override
  String get asrStandardHint => 'شافعی، مالکی، حنبلی: سایہ ایک مثل';

  @override
  String get asrHanafi => 'حنفی';

  @override
  String get asrHanafiHint => 'سایہ دو مثل';

  @override
  String get settingsHighLat => 'بلند عرض بلد کا قاعدہ';

  @override
  String get highLatAuto => 'خودکار';

  @override
  String get highLatAutoHint => '48° سے اوپر رات کا ساتواں حصہ، نیچے نصف شب';

  @override
  String get highLatMiddle => 'نصف شب';

  @override
  String get highLatSeventh => 'رات کا ساتواں حصہ';

  @override
  String get highLatTwilight => 'شفق کا زاویہ';

  @override
  String get settingsCalendar => 'کیلنڈر';

  @override
  String get settingsHijriAdjust => 'ہجری تاریخ میں ترمیم';

  @override
  String get hijriAdjustHint => 'اپنے علاقے کی رؤیتِ ہلال کے مطابق';

  @override
  String get hijriOffsetNone => 'کوئی نہیں';

  @override
  String hijriOffsetDays(String value) {
    return '$value دن';
  }

  @override
  String get settingsAttribution => 'شہروں کا ڈیٹا © GeoNames، CC BY 4.0۔ نماز کے اوقات آلے پر ہی حساب ہوتے ہیں۔';

  @override
  String get citySearchHint => 'شہر تلاش کریں';

  @override
  String cityNoResults(String query) {
    return '«$query» سے کوئی شہر نہیں ملا';
  }

  @override
  String get methodMwl => 'رابطہ عالمِ اسلامی';

  @override
  String get methodIsna => 'اسنا، شمالی امریکا';

  @override
  String get methodEgypt => 'مصری جنرل اتھارٹی برائے سروے';

  @override
  String get methodKarachi => 'جامعہ علومِ اسلامیہ، کراچی';

  @override
  String get methodUmmAlQura => 'ام القریٰ، مکہ مکرمہ';

  @override
  String get methodDubai => 'دبئی';

  @override
  String get methodQatar => 'قطر';

  @override
  String get methodKuwait => 'کویت';

  @override
  String get methodSingapore => 'سنگاپور، ملائیشیا، انڈونیشیا';

  @override
  String get methodTurkey => 'دیانت، ترکی';

  @override
  String get methodTehran => 'انسٹی ٹیوٹ آف جیو فزکس، تہران';

  @override
  String get methodMoonsighting => 'رؤیتِ ہلال کمیٹی';

  @override
  String get timesEstimated =>
      'تخمینی اوقات۔ آج یہاں سورج معمول کے مطابق طلوع یا غروب نہیں ہوتا، اس لیے اوقات 65° عرض بلد کے مطابق ہیں۔';

  @override
  String get momentLastThird => 'رات کا آخری تہائی حصہ';

  @override
  String get momentFridayLastHour => 'جمعہ کی آخری گھڑی';

  @override
  String momentAdhanIqamah(String prayer) {
    return '$prayer کی اقامت سے پہلے';
  }

  @override
  String momentAfterSalah(String prayer) {
    return '$prayer کے بعد';
  }

  @override
  String get momentRestrictedSunrise => 'طلوعِ آفتاب کا وقت';

  @override
  String get momentRestrictedZawal => 'زوال کا وقت';

  @override
  String get momentRestrictedSunset => 'غروبِ آفتاب کا وقت';

  @override
  String get momentDuha => 'چاشت';

  @override
  String get momentMorningAdhkar => 'صبح کے اذکار';

  @override
  String get momentEveningAdhkar => 'شام کے اذکار';

  @override
  String get kindRestricted => 'نفل نماز کا مکروہ وقت';

  @override
  String get rightNow => 'ابھی';

  @override
  String until(String time) {
    return '$time تک';
  }

  @override
  String get comingUp => 'آگے';

  @override
  String startsAt(String time) {
    return '$time پر';
  }

  @override
  String startsIn(String time) {
    return '$time میں';
  }

  @override
  String get timelineNow => 'ابھی';

  @override
  String get debugJump => 'Jump to moment';

  @override
  String get statusDraft => 'مسودہ';

  @override
  String get statusChecked => 'جانچا گیا';

  @override
  String get draftNotice => 'غیر جانچا مسودہ، صرف ترقیاتی ورژن میں دکھائی دیتا ہے';

  @override
  String get collectionQuran => 'قرآن';

  @override
  String get collectionBukhari => 'بخاری';

  @override
  String get collectionMuslim => 'مسلم';

  @override
  String get collectionAbudawud => 'ابو داؤد';

  @override
  String get collectionTirmidhi => 'ترمذی';

  @override
  String get collectionNasai => 'نسائی';

  @override
  String get collectionIbnmajah => 'ابن ماجہ';

  @override
  String get collectionMalik => 'مؤطا امام مالک';

  @override
  String get collectionAhmad => 'احمد';

  @override
  String get collectionDarimi => 'دارمی';

  @override
  String get collectionAdab => 'الادب المفرد';

  @override
  String get collectionHakim => 'حاکم';

  @override
  String get collectionIbnhibban => 'ابن حبان';

  @override
  String get collectionBayhaqi => 'بیہقی';

  @override
  String get collectionNasaiKubra => 'السنن الکبریٰ';

  @override
  String get sheetSource => 'ماخذ';

  @override
  String get sheetNarrator => 'راوی';

  @override
  String get sheetGrade => 'درجہ';

  @override
  String get sheetGradedBy => 'حکم لگانے والے';

  @override
  String get sheetTranslation => 'ترجمہ';

  @override
  String get sheetReview => 'جانچ';

  @override
  String sheetOpen(String host) {
    return '$host پر کھولیں';
  }

  @override
  String get sheetTextPending => 'یہ حوالہ اصل ماخذ سے جانچنے کے بعد متن یہاں ظاہر ہوگا۔';

  @override
  String get statusApproved => 'عالم سے منظور شدہ';

  @override
  String get gradeSahih => 'صحیح';

  @override
  String get gradeHasan => 'حسن';

  @override
  String reviewCheckedBy(String name) {
    return 'جانچنے والے: $name';
  }

  @override
  String reviewApprovedBy(String name) {
    return 'منظور کرنے والے: $name';
  }

  @override
  String checklistProgress(String done, String total) {
    return '$total میں سے $done';
  }

  @override
  String get checklistTitleBedtime => 'سونے سے پہلے';

  @override
  String get checklistTitleJumuah => 'جمعہ';

  @override
  String get momentJumuah => 'جمعہ';

  @override
  String get librarySearch => 'دعائیں اور حوالے تلاش کریں';

  @override
  String libraryNoMatch(String query) {
    return '«$query» کے لیے کچھ نہیں ملا';
  }

  @override
  String libraryCount(String count) {
    return '$count اندراجات';
  }

  @override
  String get libraryOther => 'دیگر';

  @override
  String get momentLastThirdShort => 'آخری تہائی';

  @override
  String reminderBody(String time, String place) {
    return '$time · $place';
  }

  @override
  String get widgetEmptyBody => 'مقام مقرر کرنے کے لیے وقت کھولیں';

  @override
  String get notifTitle => 'یاد دہانیاں';

  @override
  String get notifHint => 'نماز کے اوقات اور لمحات، آپ کی مرضی سے';

  @override
  String get notifPermission => 'اطلاعات';

  @override
  String get notifAllowed => 'اجازت ہے';

  @override
  String get notifAllow => 'اجازت دیں';

  @override
  String get notifExact => 'بروقت اطلاع';

  @override
  String get notifExactHint => 'تاکہ نماز کی یاد دہانی ٹھیک اسی منٹ پہنچے';

  @override
  String get notifBattery => 'بیٹری کی بچت';

  @override
  String get notifBatteryOk => 'غیر محدود';

  @override
  String get notifBatteryFix => 'ترتیبات کھولیں';

  @override
  String get notifBatteryHint => 'کچھ فون پس منظر میں یاد دہانیاں روک دیتے ہیں۔ وقت کو «غیر محدود» پر رکھیں۔';

  @override
  String notifBatteryHintOem(String maker) {
    return '$maker فون اکثر پس منظر میں یاد دہانیاں روک دیتے ہیں۔ وقت کو «غیر محدود» پر رکھیں۔';
  }

  @override
  String get notifPrayers => 'نماز کے اوقات';

  @override
  String get notifMoments => 'لمحات';

  @override
  String get notifSound => 'آواز';

  @override
  String get notifSoundHint => 'بند ہو تو ہر یاددہانی خاموش رہے گی';

  @override
  String notifScheduled(String count, String date) {
    return '$date تک $count یاد دہانیاں طے ہیں';
  }

  @override
  String get notifNone => 'کوئی یاد دہانی طے نہیں';

  @override
  String get notifStatus => 'صورتحال';

  @override
  String get setupCardTitle => 'نرم یاد دہانیاں';

  @override
  String get setupCardBody =>
      'ہر نماز کے وقت ایک ہلکی سی یاد دہانی۔ آپ خود منتخب کریں، اور کچھ بھی آپ کے فون سے باہر نہیں جاتا۔';

  @override
  String get setupCardAction => 'ترتیب دیں';

  @override
  String get setupCardDismiss => 'ابھی نہیں';

  @override
  String get momentLaylatAlQadr => 'آخری عشرے کی ایک طاق رات';

  @override
  String get momentSuhoor => 'سحری';

  @override
  String get momentIftar => 'افطار';

  @override
  String get occEidAlFitr => 'عید الفطر';

  @override
  String get occEidAlAdha => 'عید الاضحیٰ';

  @override
  String get occArafah => 'یومِ عرفہ';

  @override
  String get occTashreeq => 'ایامِ تشریق';

  @override
  String get occAshura => 'عاشورہ';

  @override
  String get occTasua => 'تاسوعا';

  @override
  String get occLastTen => 'آخری عشرہ';

  @override
  String occRamadan(String day) {
    return 'رمضان $day';
  }

  @override
  String get occFirstTen => 'ذوالحجہ کا پہلا عشرہ';

  @override
  String get occBid => 'ایامِ بیض';

  @override
  String get occMonday => 'پیر کا روزہ';

  @override
  String get occThursday => 'جمعرات کا روزہ';

  @override
  String get counterTitle => 'تسبیح';

  @override
  String get counterTap => 'گننے کے لیے کہیں بھی چھوئیں';

  @override
  String get counterReset => 'دوبارہ شروع';

  @override
  String counterRound(String n) {
    return 'چکر $n';
  }

  @override
  String get counterTarget => 'ہر چکر کے دانے';

  @override
  String get counterOpen => 'تسبیح کھولیں';

  @override
  String get reportContent => 'اس متن میں غلطی کی اطلاع دیں';

  @override
  String get reportProblem => 'مسئلے کی اطلاع دیں';

  @override
  String get reportProblemHint => 'ای میل کا مسودہ کھلتا ہے، بھیجنے سے پہلے آپ سب کچھ دیکھ سکتے ہیں۔';

  @override
  String get privacyTitle => 'رازداری';

  @override
  String get privacyBody => 'سب کچھ اسی فون پر حساب ہوتا ہے۔ وقت میں نہ اکاؤنٹ ہیں، نہ اشتہارات، نہ اینالیٹکس۔';

  @override
  String placeTime(String city) {
    return '$city کا وقت';
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
    return '$time باقی';
  }

  @override
  String windowPreferred(String time) {
    return 'بہتر ہے $time سے پہلے';
  }

  @override
  String durHm(String h, String m) {
    return '$h گھنٹے $m منٹ';
  }

  @override
  String durM(String m) {
    return '$m منٹ';
  }

  @override
  String get counterChoose => 'ذکر بدلیں';

  @override
  String counterStep(String n, String total) {
    return 'مرحلہ $n از $total';
  }

  @override
  String get counterFree => 'آزاد گنتی';

  @override
  String get counterFreeHint => 'اپنے ہدف کے ساتھ کچھ بھی گنیں';

  @override
  String get counterAfterSalah => 'نماز کے بعد: ۳۳ · ۳۳ · ۳۴';

  @override
  String get counterHaptics => 'ہر گنتی پر ارتعاش';

  @override
  String get counterAfterSalahName => 'نماز کے بعد';

  @override
  String get librarySearchAll => 'دعائیں اور احادیث تلاش کریں';

  @override
  String get scopeDuas => 'دعائیں';

  @override
  String get scopeHadith => 'احادیث';

  @override
  String get librarySituations => 'ہر موقع';

  @override
  String get libraryForNow => 'ابھی';

  @override
  String duaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count دعائیں', one: '1 دعا');
    return '$_temp0';
  }

  @override
  String get libraryPreparing => 'احادیث کی تلاش تیار ہو رہی ہے۔ یہ صرف ایک بار ہوتا ہے۔';

  @override
  String get libraryRefine => 'پہلے 60 دکھائے جا رہے ہیں۔ محدود کرنے کے لیے لفظ شامل کریں۔';

  @override
  String get sourceHisn =>
      'Hisn al-Muslim by Sa\'id bin Ali bin Wahf al-Qahtani. Text, transliteration and translation as published on sunnah.com, via open-hadith-data.';

  @override
  String get sourceHadith =>
      'Arabic and English as published on sunnah.com, via open-hadith-data. Grades as given by the source.';

  @override
  String hisnNumber(String n) {
    return 'حصن المسلم $n';
  }

  @override
  String get copyText => 'کاپی';

  @override
  String get copied => 'کاپی ہو گیا';

  @override
  String get openSource => 'ماخذ کھولیں';

  @override
  String get readingTitle => 'پڑھنے کا سائز';

  @override
  String get readingHint => 'عربی، تلفظ اور معنی، الگ الگ';

  @override
  String get readingArabic => 'عربی';

  @override
  String get readingTransliteration => 'تلفظ';

  @override
  String get readingMeaning => 'معنی';

  @override
  String stripLeft(String time, String prayer) {
    return '$prayer تک $time';
  }

  @override
  String get dayGuideToday => 'آج کی سنت';

  @override
  String fastToday(String day) {
    return 'آج سنت روزہ · $day';
  }

  @override
  String fastTomorrow(String day) {
    return 'کل روزہ رکھیں · $day';
  }

  @override
  String get calendarTitle => 'کیلنڈر';

  @override
  String get calendarLegendGuide => 'رہنمائی موجود';

  @override
  String get calendarLegendFast => 'سنت روزہ';

  @override
  String get calendarNote =>
      'تاریخیں ام القریٰ اور آپ کی ہجری ترمیم کے مطابق ہیں۔ شعبان، رمضان اور ذوالقعدہ کی 29 تاریخ کو ہوم پر چاند نظر آنے کا سوال آتا ہے۔';

  @override
  String sightingTitle(String month) {
    return 'کیا آپ کے ہاں $month کا چاند نظر آیا؟';
  }

  @override
  String get sightingBody =>
      'آپ کا جواب کیلنڈر کو اس طرح بدلتا ہے کہ رمضان، عید اور عرفہ آپ کی برادری کے دنوں پر آئیں۔';

  @override
  String sightingSeen(String month) {
    return 'نظر آیا: $month شروع';
  }

  @override
  String get sightingNotSeen => 'نظر نہیں آیا: 30 دن';

  @override
  String get sightingUnsure => 'یقین نہیں';

  @override
  String get ramadanSuhoor => 'سحری ختم';

  @override
  String get ramadanIftar => 'افطار';

  @override
  String ramadanIn(String time) {
    return '$time میں';
  }

  @override
  String get ramadanDone => 'مکمل';

  @override
  String announceTitle(String month) {
    return 'آج رات $month کا فیصلہ';
  }

  @override
  String announceBegins(String month, String authority) {
    return '$authority کے مطابق، $month کل شروع ہو گا۔';
  }

  @override
  String announceThirty(String month, String authority) {
    return '$authority کے مطابق، $month 30 دن کا: کل 30 تاریخ ہے۔';
  }

  @override
  String get announceOffline => 'آف لائن: آخری ڈاؤن لوڈ شدہ تاریخیں۔ کنکشن پر وقت دوبارہ چیک کرے گا۔';

  @override
  String announceChecking(String time) {
    return 'وقت آج رات ہر 30 منٹ اعلان چیک کرتا ہے۔ آخری بار $time۔';
  }

  @override
  String get authoritySaudi => 'سعودی اعلیٰ عدالتی کونسل';

  @override
  String get authorityDiyanet => 'دیانت (ترکیہ)';

  @override
  String get authorityLocal => 'مقامی رؤیت ہلال';

  @override
  String get authoritySaudiHint => 'اعلان شدہ رؤیت، آن لائن اپ ڈیٹ';

  @override
  String get authorityDiyanetHint => 'ترکیہ کا سرکاری کیلنڈر، آن لائن اپ ڈیٹ';

  @override
  String get authorityLocalHint => 'ام القریٰ؛ 29 تاریخ کو آپ بتاتے ہیں کہ چاند نظر آیا یا نہیں';

  @override
  String calendarSourceLine(String authority, String time) {
    return '$authority · $time چیک کیا';
  }

  @override
  String get calendarSourceLocal =>
      'ام القریٰ آپ کی ترمیم کے ساتھ۔ شعبان، رمضان اور ذوالقعدہ کی 29 کو ہوم پر چاند کا سوال آتا ہے۔';

  @override
  String announceUnknown(String month) {
    return 'اعلان ابھی وقت تک نہیں پہنچا۔ اگر آج رات چاند نظر آیا تو $month کل سے، ورنہ یہ مہینہ 30 دن کا ہوگا۔';
  }
}
