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
}
