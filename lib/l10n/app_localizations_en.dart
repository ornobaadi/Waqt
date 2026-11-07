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
  String get settingsDeveloper => 'Test mode';

  @override
  String get settingsDeveloperHint => 'Fake clock, day jumps and the reference checker';

  @override
  String get settingsAbout => 'About Waqt';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
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

  @override
  String get momentLastThird => 'Last third of the night';

  @override
  String get momentFridayLastHour => 'Last hour of Friday';

  @override
  String momentAdhanIqamah(String prayer) {
    return 'Before the $prayer iqamah';
  }

  @override
  String momentAfterSalah(String prayer) {
    return 'After $prayer';
  }

  @override
  String get momentRestrictedSunrise => 'Sun rising';

  @override
  String get momentRestrictedZawal => 'Sun at its zenith';

  @override
  String get momentRestrictedSunset => 'Sun setting';

  @override
  String get momentDuha => 'Duha';

  @override
  String get momentMorningAdhkar => 'Morning adhkar';

  @override
  String get momentEveningAdhkar => 'Evening adhkar';

  @override
  String get kindRestricted => 'Voluntary prayer restricted';

  @override
  String get rightNow => 'Right now';

  @override
  String until(String time) {
    return 'until $time';
  }

  @override
  String get comingUp => 'Coming up';

  @override
  String startsAt(String time) {
    return 'at $time';
  }

  @override
  String startsIn(String time) {
    return 'in $time';
  }

  @override
  String get timelineNow => 'Now';

  @override
  String get debugJump => 'Jump to moment';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusChecked => 'Checked';

  @override
  String get draftNotice => 'Unreviewed draft, shown in dev builds only';

  @override
  String get collectionQuran => 'Qur\'an';

  @override
  String get collectionBukhari => 'Bukhari';

  @override
  String get collectionMuslim => 'Muslim';

  @override
  String get collectionAbudawud => 'Abu Dawud';

  @override
  String get collectionTirmidhi => 'Tirmidhi';

  @override
  String get collectionNasai => 'Nasa\'i';

  @override
  String get collectionIbnmajah => 'Ibn Majah';

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
  String get sheetSource => 'Source';

  @override
  String get sheetNarrator => 'Narrated by';

  @override
  String get sheetGrade => 'Grade';

  @override
  String get sheetGradedBy => 'Graded by';

  @override
  String get sheetTranslation => 'Translation';

  @override
  String get sheetReview => 'Review';

  @override
  String sheetOpen(String host) {
    return 'Open on $host';
  }

  @override
  String get sheetTextPending =>
      'The text appears here once this reference has been checked against its primary source.';

  @override
  String get statusApproved => 'Scholar approved';

  @override
  String get gradeSahih => 'Sahih';

  @override
  String get gradeHasan => 'Hasan';

  @override
  String reviewCheckedBy(String name) {
    return 'Checked by $name';
  }

  @override
  String reviewApprovedBy(String name) {
    return 'Approved by $name';
  }

  @override
  String checklistProgress(String done, String total) {
    return '$done of $total';
  }

  @override
  String get checklistTitleBedtime => 'Before you sleep';

  @override
  String get checklistTitleJumuah => 'Jumu\'ah';

  @override
  String get momentJumuah => 'Jumu\'ah';

  @override
  String get librarySearch => 'Search duas and references';

  @override
  String libraryNoMatch(String query) {
    return 'Nothing matches “$query”';
  }

  @override
  String libraryCount(String count) {
    return '$count items';
  }

  @override
  String get libraryOther => 'Other';

  @override
  String get momentLastThirdShort => 'Last third';

  @override
  String reminderBody(String time, String place) {
    return '$time · $place';
  }

  @override
  String get widgetEmptyBody => 'Open Waqt to set your location';

  @override
  String get notifTitle => 'Reminders';

  @override
  String get notifHint => 'Adhkar, Jumu\'ah and night reminders, as you choose';

  @override
  String get notifPermission => 'Notifications';

  @override
  String get notifAllowed => 'Allowed';

  @override
  String get notifAllow => 'Allow';

  @override
  String get notifExact => 'On-time delivery';

  @override
  String get notifExactHint => 'Lets prayer reminders arrive at the exact minute';

  @override
  String get notifBattery => 'Battery optimisation';

  @override
  String get notifBatteryOk => 'Unrestricted';

  @override
  String get notifBatteryFix => 'Open settings';

  @override
  String get notifBatteryHint => 'Some phones stop reminders in the background. Set Waqt to Unrestricted.';

  @override
  String notifBatteryHintOem(String maker) {
    return '$maker phones often stop reminders in the background. Set Waqt to Unrestricted.';
  }

  @override
  String get notifPrayers => 'Prayer times';

  @override
  String get notifMoments => 'Moments';

  @override
  String get notifSound => 'Play sound';

  @override
  String get notifSoundHint => 'Off keeps every reminder silent';

  @override
  String notifScheduled(String count, String date) {
    return '$count reminders scheduled until $date';
  }

  @override
  String get notifNone => 'No reminders scheduled';

  @override
  String get notifStatus => 'Status';

  @override
  String get setupCardTitle => 'Gentle reminders';

  @override
  String get setupCardBody => 'A quiet nudge at each prayer time. You choose which, and nothing leaves your phone.';

  @override
  String get setupCardAction => 'Set up';

  @override
  String get setupCardDismiss => 'Not now';

  @override
  String get momentLaylatAlQadr => 'An odd night of the last ten';

  @override
  String get momentSuhoor => 'Suhoor';

  @override
  String get momentIftar => 'Iftar';

  @override
  String get occEidAlFitr => 'Eid al-Fitr';

  @override
  String get occEidAlAdha => 'Eid al-Adha';

  @override
  String get occArafah => 'Day of Arafah';

  @override
  String get occTashreeq => 'Days of Tashreeq';

  @override
  String get occAshura => 'Ashura';

  @override
  String get occTasua => 'Tasu\'a';

  @override
  String get occLastTen => 'Last ten nights';

  @override
  String occRamadan(String day) {
    return 'Ramadan $day';
  }

  @override
  String get occFirstTen => 'First ten of Dhul Hijjah';

  @override
  String get occBid => 'Ayyam al-Bid';

  @override
  String get occMonday => 'Monday fast';

  @override
  String get occThursday => 'Thursday fast';

  @override
  String get counterTitle => 'Counter';

  @override
  String get counterTap => 'Tap anywhere to count';

  @override
  String get counterReset => 'Reset';

  @override
  String counterRound(String n) {
    return 'Round $n';
  }

  @override
  String get counterTarget => 'Beads per round';

  @override
  String get counterOpen => 'Open counter';

  @override
  String get reportContent => 'Report an issue with this text';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String get reportProblemHint => 'Opens an email draft. You see everything before it is sent.';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyBody => 'Everything is calculated on this phone. Waqt has no accounts, ads or analytics.';

  @override
  String placeTime(String city) {
    return '$city time';
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
    return '$time left';
  }

  @override
  String windowPreferred(String time) {
    return 'best before $time';
  }

  @override
  String durHm(String h, String m) {
    return '$h h $m min';
  }

  @override
  String durM(String m) {
    return '$m min';
  }

  @override
  String get counterChoose => 'Change dhikr';

  @override
  String counterStep(String n, String total) {
    return 'Step $n of $total';
  }

  @override
  String get counterFree => 'Free count';

  @override
  String get counterFreeHint => 'Count anything, with your own target';

  @override
  String get counterAfterSalah => 'After salah: 33 · 33 · 34';

  @override
  String get counterHaptics => 'Vibrate on each count';

  @override
  String get counterAfterSalahName => 'After salah';

  @override
  String get librarySearchAll => 'Search duas and hadith';

  @override
  String get scopeDuas => 'Duas';

  @override
  String get scopeHadith => 'Hadith';

  @override
  String get librarySituations => 'Every situation';

  @override
  String get libraryForNow => 'For now';

  @override
  String duaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count duas', one: '1 dua');
    return '$_temp0';
  }

  @override
  String get libraryPreparing => 'Preparing hadith search. This happens once.';

  @override
  String get libraryRefine => 'Showing the first 60. Add a word to narrow it.';

  @override
  String get sourceHisn =>
      'Hisn al-Muslim by Sa\'id bin Ali bin Wahf al-Qahtani. Text, transliteration and translation as published on sunnah.com, via open-hadith-data.';

  @override
  String get sourceHadith =>
      'Arabic and English as published on sunnah.com, via open-hadith-data. Grades as given by the source.';

  @override
  String hisnNumber(String n) {
    return 'Hisn al-Muslim $n';
  }

  @override
  String get copyText => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get openSource => 'Open source';

  @override
  String get readingTitle => 'Reading size';

  @override
  String get readingHint => 'Arabic, transliteration and meaning, each on its own';

  @override
  String get readingArabic => 'Arabic';

  @override
  String get readingTransliteration => 'Transliteration';

  @override
  String get readingMeaning => 'Meaning';

  @override
  String stripLeft(String time, String prayer) {
    return '$time until $prayer';
  }

  @override
  String get dayGuideToday => 'Today\'s Sunnah';

  @override
  String fastToday(String day) {
    return 'Sunnah fast today · $day';
  }

  @override
  String fastTomorrow(String day) {
    return 'Fast tomorrow · $day';
  }

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarLegendGuide => 'Has a guide';

  @override
  String get calendarLegendFast => 'Sunnah fast';

  @override
  String get calendarNote =>
      'Dates follow Umm al-Qura with your Hijri adjustment. On the 29th of Shaban, Ramadan and Dhul Qadah, Home asks whether the new moon was seen.';

  @override
  String sightingTitle(String month) {
    return 'Was the new moon of $month seen where you are?';
  }

  @override
  String get sightingBody =>
      'Your answer moves the calendar so Ramadan, Eid and Arafah fall on the days your community keeps.';

  @override
  String sightingSeen(String month) {
    return 'Seen: $month begins';
  }

  @override
  String get sightingNotSeen => 'Not seen: 30 days';

  @override
  String get sightingUnsure => 'Not sure';

  @override
  String get ramadanSuhoor => 'Suhoor ends';

  @override
  String get ramadanIftar => 'Iftar';

  @override
  String ramadanIn(String time) {
    return 'in $time';
  }

  @override
  String get ramadanDone => 'done';

  @override
  String announceTitle(String month) {
    return 'Tonight decides $month';
  }

  @override
  String announceBegins(String month, String authority) {
    return 'By the $authority, $month begins tomorrow.';
  }

  @override
  String announceThirty(String month, String authority) {
    return 'By the $authority, $month completes 30 days: tomorrow is the 30th.';
  }

  @override
  String get announceOffline =>
      'Offline: showing the last downloaded dates. Waqt will check again when you are connected.';

  @override
  String announceChecking(String time) {
    return 'Waqt checks for the announcement every 30 minutes tonight. Last checked $time.';
  }

  @override
  String get authoritySaudi => 'Saudi High Judiciary Council';

  @override
  String get authorityDiyanet => 'Diyanet (Türkiye)';

  @override
  String get authorityLocal => 'Local moon sighting';

  @override
  String get authoritySaudiHint => 'Announced sightings, updated online';

  @override
  String get authorityDiyanetHint => 'Türkiye\'s official calendar, updated online';

  @override
  String get authorityLocalHint => 'Umm al-Qura; on the 29th you say whether the moon was seen';

  @override
  String calendarSourceLine(String authority, String time) {
    return '$authority · checked $time';
  }

  @override
  String get calendarSourceLocal =>
      'Umm al-Qura with your adjustment. On the 29th of Shaban, Ramadan and Dhul Qadah, Home asks whether the new moon was seen.';

  @override
  String announceUnknown(String month) {
    return 'The announcement has not reached Waqt yet. If the crescent is seen tonight, $month begins tomorrow; if not, this month completes 30 days.';
  }

  @override
  String get adjustTitle => 'Adjust times';

  @override
  String get adjustRowHint => 'Match your local timetable or mosque';

  @override
  String get adjustNone => 'None';

  @override
  String adjustSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count times', one: '1 time');
    return '$_temp0';
  }

  @override
  String get adjustHint =>
      'Times are calculated for your exact position. If your local timetable (for example your country\'s Islamic Foundation, or your mosque) differs by a minute or two, match it here.';

  @override
  String get adjustNote =>
      'Suhoor ends at Fajr and iftar is at Maghrib, so adjusting those moves suhoor and iftar too. Reminders and the widget follow.';

  @override
  String get adjustEarlier => '1 minute earlier';

  @override
  String get adjustLater => '1 minute later';

  @override
  String get momentTaraweeh => 'Taraweeh';

  @override
  String get showLess => 'Show less';

  @override
  String showAll(int count) {
    return 'Show all $count';
  }

  @override
  String get hadithUnavailable => 'Hadith search isn\'t available here. It works in the Android app.';

  @override
  String get hadithLibraryTitle => 'Hadith library';

  @override
  String get hadithLibraryBody =>
      '46,891 hadiths from 17 collections, in Arabic and English, searchable offline. Downloaded once, then always on your phone.';

  @override
  String hadithLibraryDownload(String mb) {
    return 'Download ($mb MB)';
  }

  @override
  String hadithLibraryProgress(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get hadithLibraryFailed => 'The download didn\'t finish. Check your connection.';

  @override
  String get hadithLibraryRetry => 'Try again';

  @override
  String get hadithLibraryNote =>
      'From open-hadith-data (texts as on sunnah.com). Verified before use. Duas and dhikr work without it.';

  @override
  String counterToday(String count) {
    return 'Today $count';
  }

  @override
  String get counterTodayTitle => 'Said today';

  @override
  String get counterTodayAll => 'All dhikr';

  @override
  String get counterResetRound => 'Restart this round';

  @override
  String get debugScenarios => 'Scenarios';

  @override
  String get debugState => 'What the app sees';

  @override
  String get debugData => 'Data';

  @override
  String get debugRefreshCalendar => 'Check the calendar now';

  @override
  String get debugClearTicks => 'Clear today\'s ticks';

  @override
  String get debugClearCounter => 'Clear the counter';

  @override
  String get debugClearSightings => 'Forget moon-sighting answers';

  @override
  String get debugRemoveHadith => 'Remove the hadith library';

  @override
  String get debugDone => 'Done';

  @override
  String get debugScEveRamadan => '29 Shaban evening';

  @override
  String get debugScSuhoor => 'Ramadan suhoor';

  @override
  String get debugScIftar => 'Ramadan iftar';

  @override
  String get debugScTaraweeh => 'Taraweeh';

  @override
  String get debugScQadr => '27th night, last third';

  @override
  String get debugScEveEid => '29 Ramadan evening';

  @override
  String get debugScEid => 'Eid al-Fitr morning';

  @override
  String get debugScArafah => 'Arafah';

  @override
  String get debugScAshura => 'Ashura';
}
