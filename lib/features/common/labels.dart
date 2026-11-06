import '../../domain/hijri/hijri_service.dart';
import '../../domain/prayer/prayer_settings.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/location/gps.dart';

/// Enum → localised label, in one place.
extension WaqtLabels on AppLocalizations {
  String waqt(Waqt w) => switch (w) {
    Waqt.fajr => prayerFajr,
    Waqt.sunrise => prayerSunrise,
    Waqt.dhuhr => prayerDhuhr,
    Waqt.asr => prayerAsr,
    Waqt.maghrib => prayerMaghrib,
    Waqt.isha => prayerIsha,
  };

  /// The span after sunrise isn't a prayer; name it as a time of day.
  String currentWaqt(Waqt w) => w == Waqt.sunrise ? waqtMorning : waqt(w);

  String method(CalcMethod m) => switch (m) {
    CalcMethod.mwl => methodMwl,
    CalcMethod.isna => methodIsna,
    CalcMethod.egypt => methodEgypt,
    CalcMethod.karachi => methodKarachi,
    CalcMethod.ummAlQura => methodUmmAlQura,
    CalcMethod.dubai => methodDubai,
    CalcMethod.qatar => methodQatar,
    CalcMethod.kuwait => methodKuwait,
    CalcMethod.singapore => methodSingapore,
    CalcMethod.turkey => methodTurkey,
    CalcMethod.tehran => methodTehran,
    CalcMethod.moonsighting => methodMoonsighting,
  };

  String asr(AsrSchool a) => a == AsrSchool.hanafi ? asrHanafi : asrStandard;

  String highLat(HighLatitudeRule r) => switch (r) {
    HighLatitudeRule.auto => highLatAuto,
    HighLatitudeRule.middleOfNight => highLatMiddle,
    HighLatitudeRule.seventhOfNight => highLatSeventh,
    HighLatitudeRule.twilightAngle => highLatTwilight,
  };

  String hijriMonth(int m) => [
    hijriMonth1, hijriMonth2, hijriMonth3, hijriMonth4, hijriMonth5, hijriMonth6, //
    hijriMonth7, hijriMonth8, hijriMonth9, hijriMonth10, hijriMonth11, hijriMonth12,
  ][m - 1];

  String hijri(HijriDate d, String Function(int) n) => hijriDate(n(d.day), hijriMonth(d.month), n(d.year));

  String gps(GpsError e) => switch (e) {
    GpsError.serviceOff => gpsServiceOff,
    GpsError.denied => gpsDenied,
    GpsError.deniedForever => gpsDeniedForever,
    GpsError.timeout || GpsError.unknown => gpsTimeout,
  };

  String hijriOffset(int d) => d == 0 ? hijriOffsetNone : hijriOffsetDays(d > 0 ? '+$d' : '−${d.abs()}');
}
