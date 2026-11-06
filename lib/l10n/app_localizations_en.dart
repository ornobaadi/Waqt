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
}
