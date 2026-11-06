// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Waqt';

  @override
  String get navNow => 'Now';

  @override
  String get navToday => 'Today';

  @override
  String get navDuas => 'Duas';

  @override
  String get navSettings => 'Settings';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get momentNight => 'Night';

  @override
  String get momentBedtime => 'Bedtime';

  @override
  String get timePending => '–';

  @override
  String get nowLocationTitle => 'Where are you praying from?';

  @override
  String get nowLocationBody =>
      'Prayer times are calculated on your phone from your location. Nothing leaves the device.';

  @override
  String get todayEmptyTitle => 'Your day, moment by moment';

  @override
  String get todayEmptyBody =>
      'Every window of today, from Fajr to the last third of the night, will line up here once prayer times are calculated.';

  @override
  String get duasEmptyTitle => 'Only verified sources';

  @override
  String get duasEmptyBody =>
      'The library opens once each item has been checked against its primary source and approved by a scholar.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Device language';

  @override
  String get settingsDeveloper => 'Developer';

  @override
  String get settingsDeveloperHint => 'Fake clock and moment palettes';

  @override
  String get settingsAbout => 'About Waqt';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
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
  String get waqtMorning => 'Morning';

  @override
  String nextIn(String prayer, String time) {
    return '$prayer in $time';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year AH';
  }

  @override
  String get hijriMonth1 => 'Muharram';

  @override
  String get hijriMonth2 => 'Safar';

  @override
  String get hijriMonth3 => 'Rabi al-Awwal';

  @override
  String get hijriMonth4 => 'Rabi al-Thani';

  @override
  String get hijriMonth5 => 'Jumada al-Ula';

  @override
  String get hijriMonth6 => 'Jumada al-Akhirah';

  @override
  String get hijriMonth7 => 'Rajab';

  @override
  String get hijriMonth8 => 'Sha\'ban';

  @override
  String get hijriMonth9 => 'Ramadan';

  @override
  String get hijriMonth10 => 'Shawwal';

  @override
  String get hijriMonth11 => 'Dhu al-Qa\'dah';

  @override
  String get hijriMonth12 => 'Dhu al-Hijjah';

  @override
  String get locationUseGps => 'Use my location';

  @override
  String get locationChooseCity => 'Choose a city';

  @override
  String get locationLocating => 'Finding you…';

  @override
  String get gpsServiceOff => 'Location is turned off on this phone. Turn it on, or choose a city.';

  @override
  String get gpsDenied => 'Location permission was declined. You can choose a city instead.';

  @override
  String get gpsDeniedForever => 'Location permission is blocked. Allow it in settings, or choose a city.';

  @override
  String get gpsTimeout => 'Couldn\'t get a fix. Try again, or choose a city.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsNotSet => 'Not set';

  @override
  String get settingsUseGps => 'Use current location';

  @override
  String get settingsGpsSource => 'From GPS';

  @override
  String get settingsPrayerTimes => 'Prayer times';

  @override
  String get settingsMethod => 'Calculation method';

  @override
  String get settingsRegionalDefault => 'Default for your region';

  @override
  String get settingsAsr => 'Asr time';

  @override
  String get asrStandard => 'Standard';

  @override
  String get asrStandardHint => 'Shafi\'i, Maliki, Hanbali: shadow equals object length';

  @override
  String get asrHanafi => 'Hanafi';

  @override
  String get asrHanafiHint => 'Shadow twice the object length';

  @override
  String get settingsHighLat => 'High-latitude rule';

  @override
  String get highLatAuto => 'Automatic';

  @override
  String get highLatAutoHint => 'Seventh of the night above 48°, middle of the night below';

  @override
  String get highLatMiddle => 'Middle of the night';

  @override
  String get highLatSeventh => 'Seventh of the night';

  @override
  String get highLatTwilight => 'Twilight angle';

  @override
  String get settingsCalendar => 'Calendar';

  @override
  String get settingsHijriAdjust => 'Hijri date adjustment';

  @override
  String get hijriAdjustHint => 'Match the moon sighting where you live';

  @override
  String get hijriOffsetNone => 'None';

  @override
  String hijriOffsetDays(String value) {
    return '$value d';
  }

  @override
  String get settingsAttribution => 'City data © GeoNames, CC BY 4.0. Prayer times calculated on device.';

  @override
  String get citySearchHint => 'Search for a city';

  @override
  String cityNoResults(String query) {
    return 'No cities match “$query”';
  }

  @override
  String get methodMwl => 'Muslim World League';

  @override
  String get methodIsna => 'ISNA, North America';

  @override
  String get methodEgypt => 'Egyptian General Authority of Survey';

  @override
  String get methodKarachi => 'University of Islamic Sciences, Karachi';

  @override
  String get methodUmmAlQura => 'Umm al-Qura, Makkah';

  @override
  String get methodDubai => 'Dubai';

  @override
  String get methodQatar => 'Qatar';

  @override
  String get methodKuwait => 'Kuwait';

  @override
  String get methodSingapore => 'Singapore, Malaysia, Indonesia';

  @override
  String get methodTurkey => 'Diyanet, Türkiye';

  @override
  String get methodTehran => 'Institute of Geophysics, Tehran';

  @override
  String get methodMoonsighting => 'Moonsighting Committee';

  @override
  String get timesEstimated =>
      'Estimated. The sun doesn\'t rise or set normally here today, so times follow latitude 65°.';
}
