import '../../data/content/content_repository.dart';
import '../../domain/hijri/hijri_service.dart';
import '../../domain/moments/moment.dart';
import '../../domain/occasions/occasions.dart';
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

  String moment(Moment m) {
    final prayer = m.prayer == null ? '' : momentId(m.prayer!);
    return switch (m.id) {
      MomentId.betweenAdhanIqamah => momentAdhanIqamah(prayer),
      MomentId.afterSalah => momentAfterSalah(prayer),
      _ => momentId(m.id),
    };
  }

  String momentId(MomentId id) => switch (id) {
    MomentId.fajr => prayerFajr,
    MomentId.sunrise => waqtMorning,
    MomentId.dhuhr => prayerDhuhr,
    MomentId.asr => prayerAsr,
    MomentId.maghrib => prayerMaghrib,
    MomentId.isha => prayerIsha,
    MomentId.morningAdhkar => momentMorningAdhkar,
    MomentId.eveningAdhkar => momentEveningAdhkar,
    MomentId.duha => momentDuha,
    MomentId.bedtime => momentBedtime,
    MomentId.lastThird => momentLastThird,
    MomentId.laylatAlQadr => momentLaylatAlQadr,
    MomentId.suhoor => momentSuhoor,
    MomentId.iftar => momentIftar,
    MomentId.jumuah => momentJumuah,
    MomentId.fridayLastHour => momentFridayLastHour,
    MomentId.betweenAdhanIqamah => momentAdhanIqamah(''),
    MomentId.afterSalah => momentAfterSalah(''),
    MomentId.restrictedSunrise => momentRestrictedSunrise,
    MomentId.restrictedZawal => momentRestrictedZawal,
    MomentId.restrictedSunset => momentRestrictedSunset,
  };

  String collection(String c) => switch (c) {
    'quran' => collectionQuran,
    'bukhari' => collectionBukhari,
    'muslim' => collectionMuslim,
    'abudawud' => collectionAbudawud,
    'tirmidhi' => collectionTirmidhi,
    'nasai' => collectionNasai,
    'ibnmajah' => collectionIbnmajah,
    'malik' => collectionMalik,
    'ahmad' => collectionAhmad,
    'darimi' => collectionDarimi,
    'adab' => collectionAdab,
    'hakim' => collectionHakim,
    'ibnhibban' => collectionIbnhibban,
    'bayhaqi' => collectionBayhaqi,
    'nasai_kubra' => collectionNasaiKubra,
    _ => c,
  };

  /// "Bukhari 1145", "Qur'an 51:18".
  String reference(ContentSource s) => '${collection(s.collection)} ${s.number}';

  String occasion(OccasionId o, {required String ramadanDay}) => switch (o) {
    OccasionId.eidAlFitr => occEidAlFitr,
    OccasionId.eidAlAdha => occEidAlAdha,
    OccasionId.arafah => occArafah,
    OccasionId.tashreeq => occTashreeq,
    OccasionId.ashura => occAshura,
    OccasionId.tasua => occTasua,
    OccasionId.lastTenNights => occLastTen,
    OccasionId.ramadan => occRamadan(ramadanDay),
    OccasionId.firstTenDhulHijjah => occFirstTen,
    OccasionId.ayyamAlBid => occBid,
    OccasionId.jumuah => momentJumuah,
    OccasionId.mondayFast => occMonday,
    OccasionId.thursdayFast => occThursday,
  };
}
