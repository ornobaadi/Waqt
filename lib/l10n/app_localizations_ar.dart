// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'وقت';

  @override
  String get navNow => 'الآن';

  @override
  String get navToday => 'اليوم';

  @override
  String get navDuas => 'الأدعية';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get momentNight => 'الليل';

  @override
  String get momentBedtime => 'النوم';

  @override
  String get timePending => '–';

  @override
  String get nowLocationTitle => 'من أين تصلي؟';

  @override
  String get nowLocationBody => 'تُحسب أوقات الصلاة على هاتفك من موقعك. لا يغادر شيء جهازك.';

  @override
  String get todayEmptyTitle => 'يومك، لحظةً بلحظة';

  @override
  String get todayEmptyBody => 'ستظهر هنا كل أوقات اليوم، من الفجر إلى الثلث الأخير من الليل، بعد حساب أوقات الصلاة.';

  @override
  String get duasEmptyTitle => 'مصادر موثّقة فقط';

  @override
  String get duasEmptyBody => 'تُفتح المكتبة بعد مراجعة كل نص على مصدره الأصلي واعتماده من عالم شرعي.';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSystem => 'لغة الجهاز';

  @override
  String get settingsDeveloper => 'المطوّر';

  @override
  String get settingsDeveloperHint => 'ساعة تجريبية وألوان الأوقات';

  @override
  String get settingsAbout => 'عن وقت';

  @override
  String settingsVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get debugTitle => 'المطوّر';

  @override
  String get debugClock => 'الساعة';

  @override
  String get debugClockReal => 'الوقت الحقيقي';

  @override
  String get debugClockFaked => 'وقت تجريبي';

  @override
  String get debugPickDate => 'التاريخ';

  @override
  String get debugPickTime => 'الوقت';

  @override
  String get debugReset => 'إعادة ضبط';

  @override
  String get debugPalette => 'ألوان الوقت';

  @override
  String get debugPaletteAuto => 'تلقائي';

  @override
  String get debugDirection => 'اتجاه الواجهة';

  @override
  String get debugBuild => 'البناء';

  @override
  String get waqtMorning => 'الضحى';

  @override
  String nextIn(String prayer, String time) {
    return '$prayer بعد $time';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year هـ';
  }

  @override
  String get hijriMonth1 => 'محرم';

  @override
  String get hijriMonth2 => 'صفر';

  @override
  String get hijriMonth3 => 'ربيع الأول';

  @override
  String get hijriMonth4 => 'ربيع الآخر';

  @override
  String get hijriMonth5 => 'جمادى الأولى';

  @override
  String get hijriMonth6 => 'جمادى الآخرة';

  @override
  String get hijriMonth7 => 'رجب';

  @override
  String get hijriMonth8 => 'شعبان';

  @override
  String get hijriMonth9 => 'رمضان';

  @override
  String get hijriMonth10 => 'شوال';

  @override
  String get hijriMonth11 => 'ذو القعدة';

  @override
  String get hijriMonth12 => 'ذو الحجة';

  @override
  String get locationUseGps => 'استخدم موقعي';

  @override
  String get locationChooseCity => 'اختر مدينة';

  @override
  String get locationLocating => 'جارٍ تحديد موقعك…';

  @override
  String get gpsServiceOff => 'خدمة الموقع متوقفة على هذا الهاتف. شغّلها أو اختر مدينة.';

  @override
  String get gpsDenied => 'تم رفض إذن الموقع. يمكنك اختيار مدينة بدلاً من ذلك.';

  @override
  String get gpsDeniedForever => 'إذن الموقع محظور. اسمح به من الإعدادات أو اختر مدينة.';

  @override
  String get gpsTimeout => 'تعذّر تحديد الموقع. حاول مجددًا أو اختر مدينة.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get settingsLocation => 'الموقع';

  @override
  String get settingsNotSet => 'غير محدد';

  @override
  String get settingsUseGps => 'استخدم الموقع الحالي';

  @override
  String get settingsGpsSource => 'من GPS';

  @override
  String get settingsPrayerTimes => 'أوقات الصلاة';

  @override
  String get settingsMethod => 'طريقة الحساب';

  @override
  String get settingsRegionalDefault => 'الافتراضي لمنطقتك';

  @override
  String get settingsAsr => 'وقت العصر';

  @override
  String get asrStandard => 'الجمهور';

  @override
  String get asrStandardHint => 'الشافعي والمالكي والحنبلي: ظل الشيء مثله';

  @override
  String get asrHanafi => 'الحنفي';

  @override
  String get asrHanafiHint => 'ظل الشيء مثلاه';

  @override
  String get settingsHighLat => 'قاعدة خطوط العرض العليا';

  @override
  String get highLatAuto => 'تلقائي';

  @override
  String get highLatAutoHint => 'سُبع الليل فوق خط عرض 48°، ومنتصف الليل دونه';

  @override
  String get highLatMiddle => 'منتصف الليل';

  @override
  String get highLatSeventh => 'سُبع الليل';

  @override
  String get highLatTwilight => 'زاوية الشفق';

  @override
  String get settingsCalendar => 'التقويم';

  @override
  String get settingsHijriAdjust => 'تعديل التاريخ الهجري';

  @override
  String get hijriAdjustHint => 'ليوافق رؤية الهلال في بلدك';

  @override
  String get hijriOffsetNone => 'بدون';

  @override
  String hijriOffsetDays(String value) {
    return '$value يوم';
  }

  @override
  String get settingsAttribution => 'بيانات المدن © GeoNames بترخيص CC BY 4.0. تُحسب أوقات الصلاة على الجهاز.';

  @override
  String get citySearchHint => 'ابحث عن مدينة';

  @override
  String cityNoResults(String query) {
    return 'لا توجد مدن تطابق «$query»';
  }

  @override
  String get methodMwl => 'رابطة العالم الإسلامي';

  @override
  String get methodIsna => 'الجمعية الإسلامية لأمريكا الشمالية';

  @override
  String get methodEgypt => 'الهيئة المصرية العامة للمساحة';

  @override
  String get methodKarachi => 'جامعة العلوم الإسلامية، كراتشي';

  @override
  String get methodUmmAlQura => 'أم القرى، مكة المكرمة';

  @override
  String get methodDubai => 'دبي';

  @override
  String get methodQatar => 'قطر';

  @override
  String get methodKuwait => 'الكويت';

  @override
  String get methodSingapore => 'سنغافورة وماليزيا وإندونيسيا';

  @override
  String get methodTurkey => 'رئاسة الشؤون الدينية، تركيا';

  @override
  String get methodTehran => 'معهد الجيوفيزياء، طهران';

  @override
  String get methodMoonsighting => 'لجنة رؤية الهلال';

  @override
  String get timesEstimated => 'أوقات تقديرية: لا تشرق الشمس أو تغرب على المعتاد هنا اليوم، فتُحسب على خط عرض 65°.';

  @override
  String get momentLastThird => 'الثلث الأخير من الليل';

  @override
  String get momentFridayLastHour => 'الساعة الأخيرة من الجمعة';

  @override
  String momentAdhanIqamah(String prayer) {
    return 'قبل إقامة $prayer';
  }

  @override
  String momentAfterSalah(String prayer) {
    return 'بعد صلاة $prayer';
  }

  @override
  String get momentRestrictedSunrise => 'وقت الشروق';

  @override
  String get momentRestrictedZawal => 'وقت الزوال';

  @override
  String get momentRestrictedSunset => 'وقت الغروب';

  @override
  String get momentDuha => 'الضحى';

  @override
  String get momentMorningAdhkar => 'أذكار الصباح';

  @override
  String get momentEveningAdhkar => 'أذكار المساء';

  @override
  String get kindRestricted => 'وقت كراهة للنافلة';

  @override
  String get rightNow => 'الآن';

  @override
  String until(String time) {
    return 'حتى $time';
  }

  @override
  String get comingUp => 'قريبًا';

  @override
  String startsAt(String time) {
    return 'الساعة $time';
  }

  @override
  String startsIn(String time) {
    return 'بعد $time';
  }

  @override
  String get timelineNow => 'الآن';

  @override
  String get debugJump => 'الانتقال إلى وقت';

  @override
  String get statusDraft => 'مسودة';

  @override
  String get statusChecked => 'مُراجَع';

  @override
  String get draftNotice => 'مسودة غير مراجعة، تظهر في نسخ التطوير فقط';

  @override
  String get collectionQuran => 'القرآن';

  @override
  String get collectionBukhari => 'البخاري';

  @override
  String get collectionMuslim => 'مسلم';

  @override
  String get collectionAbudawud => 'أبو داود';

  @override
  String get collectionTirmidhi => 'الترمذي';

  @override
  String get collectionNasai => 'النسائي';

  @override
  String get collectionIbnmajah => 'ابن ماجه';

  @override
  String get collectionMalik => 'موطأ مالك';

  @override
  String get collectionAhmad => 'أحمد';

  @override
  String get collectionDarimi => 'الدارمي';

  @override
  String get collectionAdab => 'الأدب المفرد';

  @override
  String get collectionHakim => 'الحاكم';

  @override
  String get collectionIbnhibban => 'ابن حبان';

  @override
  String get collectionBayhaqi => 'البيهقي';

  @override
  String get collectionNasaiKubra => 'السنن الكبرى';

  @override
  String get sheetSource => 'المصدر';

  @override
  String get sheetNarrator => 'الراوي';

  @override
  String get sheetGrade => 'الدرجة';

  @override
  String get sheetGradedBy => 'حكم عليه';

  @override
  String get sheetTranslation => 'الترجمة';

  @override
  String get sheetReview => 'المراجعة';

  @override
  String sheetOpen(String host) {
    return 'فتح في $host';
  }

  @override
  String get sheetTextPending => 'يظهر النص هنا بعد مراجعة هذا المرجع على مصدره الأصلي.';

  @override
  String get statusApproved => 'معتمد من عالم شرعي';

  @override
  String get gradeSahih => 'صحيح';

  @override
  String get gradeHasan => 'حسن';

  @override
  String reviewCheckedBy(String name) {
    return 'راجعه $name';
  }

  @override
  String reviewApprovedBy(String name) {
    return 'اعتمده $name';
  }

  @override
  String checklistProgress(String done, String total) {
    return '$done من $total';
  }

  @override
  String get checklistTitleBedtime => 'قبل النوم';

  @override
  String get checklistTitleJumuah => 'الجمعة';

  @override
  String get momentJumuah => 'الجمعة';

  @override
  String get librarySearch => 'ابحث في الأدعية والمراجع';

  @override
  String libraryNoMatch(String query) {
    return 'لا نتائج لـ «$query»';
  }

  @override
  String libraryCount(String count) {
    return '$count عنصر';
  }

  @override
  String get libraryOther => 'أخرى';

  @override
  String get momentLastThirdShort => 'الثلث الأخير';

  @override
  String reminderBody(String time, String place) {
    return '$time · $place';
  }

  @override
  String get widgetEmptyBody => 'افتح وقت لتحديد موقعك';

  @override
  String get notifTitle => 'التذكيرات';

  @override
  String get notifHint => 'أوقات الصلاة واللحظات كما تختار';

  @override
  String get notifPermission => 'الإشعارات';

  @override
  String get notifAllowed => 'مسموح';

  @override
  String get notifAllow => 'السماح';

  @override
  String get notifExact => 'التوقيت الدقيق';

  @override
  String get notifExactHint => 'ليصل تذكير الصلاة في الدقيقة نفسها';

  @override
  String get notifBattery => 'تحسين البطارية';

  @override
  String get notifBatteryOk => 'غير مقيّد';

  @override
  String get notifBatteryFix => 'فتح الإعدادات';

  @override
  String get notifBatteryHint => 'بعض الهواتف توقف التذكيرات في الخلفية. اجعل وقت «غير مقيّد».';

  @override
  String notifBatteryHintOem(String maker) {
    return 'هواتف $maker كثيرًا ما توقف التذكيرات في الخلفية. اجعل وقت «غير مقيّد».';
  }

  @override
  String get notifPrayers => 'أوقات الصلاة';

  @override
  String get notifMoments => 'اللحظات';

  @override
  String get notifSound => 'تشغيل الصوت';

  @override
  String get notifSoundHint => 'عند الإيقاف تصل كل التذكيرات بصمت';

  @override
  String notifScheduled(String count, String date) {
    return '$count تذكيرًا مجدولًا حتى $date';
  }

  @override
  String get notifNone => 'لا توجد تذكيرات مجدولة';

  @override
  String get notifStatus => 'الحالة';

  @override
  String get setupCardTitle => 'تذكيرات هادئة';

  @override
  String get setupCardBody => 'تنبيه لطيف عند كل صلاة. أنت تختار، ولا يغادر شيء هاتفك.';

  @override
  String get setupCardAction => 'إعداد';

  @override
  String get setupCardDismiss => 'ليس الآن';

  @override
  String get momentLaylatAlQadr => 'ليلة وترية من العشر الأواخر';

  @override
  String get momentSuhoor => 'السحور';

  @override
  String get momentIftar => 'الإفطار';

  @override
  String get occEidAlFitr => 'عيد الفطر';

  @override
  String get occEidAlAdha => 'عيد الأضحى';

  @override
  String get occArafah => 'يوم عرفة';

  @override
  String get occTashreeq => 'أيام التشريق';

  @override
  String get occAshura => 'عاشوراء';

  @override
  String get occTasua => 'تاسوعاء';

  @override
  String get occLastTen => 'العشر الأواخر';

  @override
  String occRamadan(String day) {
    return 'رمضان $day';
  }

  @override
  String get occFirstTen => 'عشر ذي الحجة';

  @override
  String get occBid => 'الأيام البيض';

  @override
  String get occMonday => 'صيام الاثنين';

  @override
  String get occThursday => 'صيام الخميس';

  @override
  String get counterTitle => 'العدّاد';

  @override
  String get counterTap => 'اضغط في أي مكان للعدّ';

  @override
  String get counterReset => 'إعادة';

  @override
  String counterRound(String n) {
    return 'الدورة $n';
  }

  @override
  String get counterTarget => 'عدد الحبات في الدورة';

  @override
  String get counterOpen => 'فتح العدّاد';

  @override
  String get reportContent => 'الإبلاغ عن خطأ في هذا النص';

  @override
  String get reportProblem => 'الإبلاغ عن مشكلة';

  @override
  String get reportProblemHint => 'يفتح مسودة بريد. ترى كل شيء قبل إرساله.';

  @override
  String get privacyTitle => 'الخصوصية';

  @override
  String get privacyBody => 'كل شيء يُحسب على هذا الهاتف. لا حسابات ولا إعلانات ولا تحليلات في وقت.';

  @override
  String placeTime(String city) {
    return 'توقيت $city';
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
    return 'بقي $time';
  }

  @override
  String windowPreferred(String time) {
    return 'الأفضل قبل $time';
  }

  @override
  String durHm(String h, String m) {
    return '$h س $m د';
  }

  @override
  String durM(String m) {
    return '$m د';
  }

  @override
  String get counterChoose => 'تغيير الذكر';

  @override
  String counterStep(String n, String total) {
    return 'الخطوة $n من $total';
  }

  @override
  String get counterFree => 'عدّ حر';

  @override
  String get counterFreeHint => 'عدّ أي شيء بالهدف الذي تختاره';

  @override
  String get counterAfterSalah => 'بعد الصلاة: ٣٣ · ٣٣ · ٣٤';

  @override
  String get counterHaptics => 'اهتزاز مع كل عدّة';

  @override
  String get counterAfterSalahName => 'بعد الصلاة';

  @override
  String get librarySearchAll => 'ابحث في الأدعية والأحاديث';

  @override
  String get scopeDuas => 'الأدعية';

  @override
  String get scopeHadith => 'الأحاديث';

  @override
  String get librarySituations => 'كل المواقف';

  @override
  String get libraryForNow => 'الآن';

  @override
  String duaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count أدعية', one: 'دعاء واحد');
    return '$_temp0';
  }

  @override
  String get libraryPreparing => 'يجري تجهيز البحث في الأحاديث. يحدث هذا مرة واحدة.';

  @override
  String get libraryRefine => 'تُعرض أول ٦٠ نتيجة. أضف كلمة لتضييق البحث.';

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
  String get copyText => 'نسخ';

  @override
  String get copied => 'تم النسخ';

  @override
  String get openSource => 'فتح المصدر';

  @override
  String get readingTitle => 'حجم القراءة';

  @override
  String get readingHint => 'العربية والنطق والمعنى، كل على حدة';

  @override
  String get readingArabic => 'العربية';

  @override
  String get readingTransliteration => 'النطق';

  @override
  String get readingMeaning => 'المعنى';

  @override
  String stripLeft(String time, String prayer) {
    return '$time حتى $prayer';
  }

  @override
  String get dayGuideToday => 'سنة اليوم';

  @override
  String fastToday(String day) {
    return 'صيام سنة اليوم · $day';
  }

  @override
  String fastTomorrow(String day) {
    return 'صم غدًا · $day';
  }

  @override
  String get calendarTitle => 'التقويم';

  @override
  String get calendarLegendGuide => 'فيه إرشاد';

  @override
  String get calendarLegendFast => 'صيام سنة';

  @override
  String get calendarNote =>
      'التواريخ وفق أم القرى مع تعديلك الهجري. في التاسع والعشرين من شعبان ورمضان وذي القعدة تسألك الشاشة الرئيسية عن رؤية الهلال.';

  @override
  String sightingTitle(String month) {
    return 'هل رُئي هلال $month عندكم؟';
  }

  @override
  String get sightingBody => 'يحرك جوابك التقويم لتقع رمضان والعيد وعرفة في الأيام التي يلتزمها مجتمعك.';

  @override
  String sightingSeen(String month) {
    return 'رُئي: يبدأ $month';
  }

  @override
  String get sightingNotSeen => 'لم يُرَ: ثلاثون يومًا';

  @override
  String get sightingUnsure => 'لست متأكدًا';

  @override
  String get ramadanSuhoor => 'ينتهي السحور';

  @override
  String get ramadanIftar => 'الإفطار';

  @override
  String ramadanIn(String time) {
    return 'بعد $time';
  }

  @override
  String get ramadanDone => 'انتهى';

  @override
  String announceTitle(String month) {
    return 'الليلة يتحدد $month';
  }

  @override
  String announceBegins(String month, String authority) {
    return 'وفق $authority، يبدأ $month غدًا.';
  }

  @override
  String announceThirty(String month, String authority) {
    return 'وفق $authority، يكمل $month ثلاثين يومًا: غدًا هو الثلاثون.';
  }

  @override
  String get announceOffline => 'دون اتصال: تُعرض آخر تواريخ محمّلة. سيتحقق وقت مجددًا عند الاتصال.';

  @override
  String announceChecking(String time) {
    return 'يتحقق وقت من الإعلان كل ٣٠ دقيقة الليلة. آخر تحقق $time.';
  }

  @override
  String get authoritySaudi => 'المجلس الأعلى للقضاء السعودي';

  @override
  String get authorityDiyanet => 'ديانت (تركيا)';

  @override
  String get authorityLocal => 'رؤية الهلال المحلية';

  @override
  String get authoritySaudiHint => 'رؤية معلنة، تُحدَّث عبر الإنترنت';

  @override
  String get authorityDiyanetHint => 'التقويم الرسمي لتركيا، يُحدَّث عبر الإنترنت';

  @override
  String get authorityLocalHint => 'أم القرى؛ وفي التاسع والعشرين تخبرنا هل رُئي الهلال';

  @override
  String calendarSourceLine(String authority, String time) {
    return '$authority · آخر تحقق $time';
  }

  @override
  String get calendarSourceLocal =>
      'أم القرى مع تعديلك. في التاسع والعشرين من شعبان ورمضان وذي القعدة تسألك الشاشة الرئيسية عن رؤية الهلال.';

  @override
  String announceUnknown(String month) {
    return 'لم يصل الإعلان إلى وقت بعد. إن رُئي الهلال الليلة يبدأ $month غدًا، وإلا أكمل هذا الشهر ثلاثين يومًا.';
  }

  @override
  String get adjustTitle => 'ضبط الأوقات';

  @override
  String get adjustRowHint => 'طابق جدول بلدك أو مسجدك';

  @override
  String get adjustNone => 'لا شيء';

  @override
  String adjustSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count أوقات', one: 'وقت واحد');
    return '$_temp0';
  }

  @override
  String get adjustHint =>
      'تُحسب الأوقات لموقعك الدقيق. إن اختلف جدولك المحلي (مثل جهة الشؤون الإسلامية أو مسجدك) بدقيقة أو اثنتين فطابقه هنا.';

  @override
  String get adjustNote =>
      'ينتهي السحور عند الفجر والإفطار عند المغرب، فضبطهما يحرك السحور والإفطار أيضًا. التذكيرات والأداة تتبع ذلك.';

  @override
  String get adjustEarlier => 'دقيقة أبكر';

  @override
  String get adjustLater => 'دقيقة أخر';

  @override
  String get momentTaraweeh => 'التراويح';

  @override
  String get showLess => 'عرض أقل';

  @override
  String showAll(int count) {
    return 'عرض الكل ($count)';
  }
}
