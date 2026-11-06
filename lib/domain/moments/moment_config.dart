import '../prayer/prayer_times_service.dart';

/// Every margin here is a fiqh decision, not an engineering one. Defaults are
/// common, conservative choices and are listed in docs/moment-rules.md for
/// scholar review. Nothing in the engine hard-codes these numbers.
class MomentConfig {
  const MomentConfig({
    this.restrictedAfterSunrise = const Duration(minutes: 15),
    this.restrictedBeforeDhuhr = const Duration(minutes: 10),
    this.restrictedBeforeMaghrib = const Duration(minutes: 15),
    this.iqamahDelay = const {
      Waqt.fajr: Duration(minutes: 20),
      Waqt.dhuhr: Duration(minutes: 15),
      Waqt.asr: Duration(minutes: 15),
      Waqt.maghrib: Duration(minutes: 5),
      Waqt.isha: Duration(minutes: 15),
    },
    this.salahLength = const Duration(minutes: 10),
    this.afterSalahLength = const Duration(minutes: 20),
    this.bedtimeMinutes = 22 * 60 + 30,
    this.bedtimeLength = const Duration(hours: 2),
    this.fridayLastHour = const Duration(hours: 1),
  });

  /// Sunrise → sunrise + this: the sun is rising.
  final Duration restrictedAfterSunrise;

  /// Dhuhr − this → Dhuhr: the sun at its zenith (zawal).
  final Duration restrictedBeforeDhuhr;

  /// Maghrib − this → Maghrib: the sun is setting.
  final Duration restrictedBeforeMaghrib;

  /// Adhan → iqamah, per prayer. Local mosques differ; user-adjustable later.
  final Map<Waqt, Duration> iqamahDelay;

  /// Assumed length of the fard prayer itself.
  final Duration salahLength;

  /// The window for remembrance once the prayer is done.
  final Duration afterSalahLength;

  /// Usual bedtime as minutes after local midnight (22:30 default).
  final int bedtimeMinutes;
  final Duration bedtimeLength;

  /// The closing span of Friday before Maghrib.
  final Duration fridayLastHour;
}
