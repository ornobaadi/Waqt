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
}
