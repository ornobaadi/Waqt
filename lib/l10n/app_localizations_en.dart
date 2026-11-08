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
  String get notifHint => 'Arafah, Ashura, Jumu\'ah, Ramadan and more';

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
  String get setupCardTitle => 'Let Waqt remind you';

  @override
  String get setupCardBody => 'The night before Arafah, Ashura or Eid, and every Friday: what to do, and why.';

  @override
  String get setupCardAction => 'Turn on';

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
  String get librarySearchAll => 'Search hadith and duas';

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
      'HadeethEnc\'s encyclopedia in your language: authentic hadiths with the Arabic, grade and explanation, searchable offline. Downloaded once.';

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
      'From HadeethEnc.com, shown unchanged. Home, the checklists and the counter work without it.';

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

  @override
  String get counterAddOwn => 'Add your own';

  @override
  String get counterOwnName => 'What you\'ll say';

  @override
  String get counterOwnArabic => 'Arabic (optional)';

  @override
  String get counterOwnTarget => 'How many times';

  @override
  String get counterSave => 'Save';

  @override
  String get counterRemove => 'Remove';

  @override
  String get counterSectionReward => 'With a promised reward';

  @override
  String get counterSectionYours => 'Your own';

  @override
  String get sheetExplanation => 'Explanation';

  @override
  String get sheetEnglishOriginal => 'English (sunnah.com)';

  @override
  String sourceHadeethEnc(String date) {
    return 'Translation and explanation: HadeethEnc.com, shown unchanged (retrieved $date).';
  }

  @override
  String get openHadeethEnc => 'HadeethEnc';

  @override
  String heNotTranslated(String language) {
    return 'HadeethEnc hasn\'t translated this hadith into $language yet, so the Arabic is shown.';
  }

  @override
  String get libraryAllTopics => 'All topics';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String qiblaFrom(String city) {
    return 'From $city';
  }

  @override
  String get qiblaFacing => 'Facing the Qibla';

  @override
  String get qiblaTurnRight => 'Turn right';

  @override
  String get qiblaTurnLeft => 'Turn left';

  @override
  String get qiblaDirection => 'Direction';

  @override
  String qiblaBearing(String deg) {
    return '$deg° from north';
  }

  @override
  String get qiblaDistance => 'Distance to the Kaaba';

  @override
  String qiblaKm(String km) {
    return '$km km';
  }

  @override
  String get qiblaHoldFlat => 'Hold your phone flat';

  @override
  String get qiblaCalibrate =>
      'If the direction drifts, move your phone in a figure eight, away from metal and magnets.';

  @override
  String qiblaNoCompass(String deg) {
    return 'No compass on this device. Face $deg° from north using a landmark or the sun.';
  }

  @override
  String get qiblaNoPlace => 'Choose a city to find the Qibla.';

  @override
  String get qiblaNorthShort => 'N';

  @override
  String get footerHandcrafted => 'HANDCRAFTED BY';

  @override
  String get footerSignatureLabel => 'Signature of Ornob Aadi';

  @override
  String footerVersion(String version) {
    return 'WAQT · BETA $version';
  }

  @override
  String get footerTagline => 'OFFLINE · NO ADS · NO TRACKING';

  @override
  String get footerDuaRequest => 'Remember me in your duas.';

  @override
  String remTitle(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'ramadan': '🌙 Ramadan begins tonight',
      'dhulHijjah': '🕋 The best ten days begin',
      'arafah': '🤲 Tomorrow is the Day of Arafah',
      'eidFitr': '🎉 Eid al-Fitr is tomorrow',
      'eidAdha': '🐑 Eid al-Adha is tomorrow',
      'tasua': '🗓️ Fast Tasu\'a tomorrow',
      'ashura': '🌊 Tomorrow is Ashura',
      'whiteDays': '🌕 The white days start tomorrow',
      'monday': '🗓️ Fast tomorrow, Monday',
      'thursday': '🗓️ Fast tomorrow, Thursday',
      'jumuah': '🕌 Jumu\'ah Mubarak',
      'fridayLastHour': '🤲 The hour of Friday is here',
      'suhoor': '🌙 Time for suhoor',
      'iftar': '🌅 Time to break your fast',
      'laylatAlQadr': '✨ Tonight may be Laylat al-Qadr',
      'morningAdhkar': '☀️ Morning adhkar',
      'eveningAdhkar': '🌇 Evening adhkar',
      'lastThird': '🌌 The last third of the night',
      'bedtime': '😴 Before you sleep',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remBody(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'ramadan': 'Taraweeh tonight, suhoor before Fajr. Whoever fasts Ramadan with faith and hope of reward is forgiven his past sins (Bukhari).',
      'dhulHijjah': 'No days are good deeds more beloved to Allah than these ten (Bukhari). Takbir, fasting, charity: tap to plan them.',
      'arafah':
          'Fasting it wipes out the sins of the past year and the coming one (Muslim). Make your intention tonight.',
      'eidFitr':
          'Give zakat al-fitr before the Eid prayer, and say the takbir from tonight. Tap for the Sunnah of Eid.',
      'eidAdha': 'Say the takbir, pray Eid in the morning, then offer your sacrifice. Tap for the Sunnah of Eid.',
      'tasua': 'The Prophet ﷺ meant to fast the 9th with Ashura (Muslim). Ashura comes the day after.',
      'ashura': 'Fasting Ashura wipes out the sins of the past year (Muslim). Make your intention tonight.',
      'whiteDays': 'Fast the 13th, 14th and 15th: three days a month is like fasting the whole year (Bukhari).',
      'monday': 'Deeds are shown to Allah on Mondays and Thursdays, and the Prophet ﷺ loved to be fasting (Tirmidhi).',
      'thursday':
          'Deeds are shown to Allah on Mondays and Thursdays, and the Prophet ﷺ loved to be fasting (Tirmidhi).',
      'jumuah': 'Ghusl, go early, read Surat al-Kahf and send many blessings on the Prophet ﷺ today.',
      'fridayLastHour': 'There is an hour on Friday when every dua is answered (Bukhari). Seek it now, before Maghrib.',
      'suhoor': 'Eat suhoor, for there is blessing in it (Bukhari). Fajr is coming soon.',
      'iftar': 'People stay upon good as long as they hasten to break the fast (Bukhari). Make dua as you break it.',
      'laylatAlQadr':
          'Better than a thousand months. Pray, and say: Allahumma innaka ʿafuwwun tuhibbul-ʿafwa faʿfu ʿanni.',
      'morningAdhkar': 'A few minutes of remembrance to begin your day under Allah\'s protection.',
      'eveningAdhkar': 'The evening remembrance, before Maghrib. Tap to read it.',
      'lastThird':
          'Allah descends to the lowest heaven and asks: who is calling on Me, that I may answer him? (Bukhari)',
      'bedtime': 'Ayat al-Kursi, the last two verses of al-Baqarah and the sleep dua. Two minutes.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'ramadan': 'Start of Ramadan',
      'dhulHijjah': 'Dhul Hijjah and Arafah',
      'eid': 'Eid',
      'ashura': 'Tasu\'a and Ashura',
      'whiteDays': 'The white days',
      'monThu': 'Monday and Thursday fasts',
      'jumuah': 'Jumu\'ah morning',
      'fridayLastHour': 'The hour of Friday',
      'suhoor': 'Suhoor',
      'iftar': 'Iftar',
      'laylatAlQadr': 'Odd nights of the last ten',
      'morningAdhkar': 'Morning adhkar',
      'eveningAdhkar': 'Evening adhkar',
      'lastThird': 'The last third of the night',
      'bedtime': 'Before sleep',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remWhen(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'ramadan': 'The night Ramadan begins',
      'dhulHijjah': 'When the ten days begin, and the eve of Arafah',
      'eid': 'The evening before each Eid',
      'ashura': 'The evenings before the 9th and 10th of Muharram',
      'whiteDays': 'The evening before the 13th, every month',
      'monThu': 'Sunday and Wednesday evenings',
      'jumuah': 'Friday morning',
      'fridayLastHour': 'Friday, the last hour before Maghrib',
      'suhoor': 'Before Fajr, every day of Ramadan',
      'iftar': 'At Maghrib, every day of Ramadan',
      'laylatAlQadr': 'Nights of the 21st, 23rd, 25th, 27th and 29th',
      'morningAdhkar': 'After Fajr',
      'eveningAdhkar': 'After Asr',
      'lastThird': 'When the last third begins',
      'bedtime': 'At your bedtime',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get remHeroTitle => 'Never miss the moments that count';

  @override
  String get remHeroBody =>
      'Waqt reminds you only at the most rewarded times: Arafah, Ashura, Laylat al-Qadr, every Friday. Each reminder says what to do and why, with its source.';

  @override
  String get remTurnOn => 'Turn on reminders';

  @override
  String get remComingUp => 'Coming up';

  @override
  String get remNothingSoon => 'Nothing in the next month. Turn on more reminders below.';

  @override
  String get remPreview => 'Preview';

  @override
  String get remTest => 'Send me a test reminder';

  @override
  String get remTestSent => 'Sent. Check your notifications.';

  @override
  String get remNow => 'now';

  @override
  String get remGroupSpecial => 'Special days';

  @override
  String get remGroupFriday => 'Every Friday';

  @override
  String get remGroupRamadan => 'In Ramadan';

  @override
  String get remGroupDaily => 'Every day';

  @override
  String get remDailyNote => 'Off by default, so the most important reminders stand out.';

  @override
  String get qiblaFromLabel => 'Qibla from';

  @override
  String get qiblaToLeft => 'to your left';

  @override
  String get qiblaToRight => 'to your right';

  @override
  String qiblaToMakkah(String km) {
    return '$km km to Makkah';
  }

  @override
  String get qiblaHint => 'Turn until the arrow points up and the screen glows.';

  @override
  String get deedOnTime => 'Prayed on time';

  @override
  String get deedJamaah => 'In congregation';

  @override
  String get deedQada => 'Made up later';

  @override
  String get deedNotPrayed => 'Not marked';

  @override
  String deedPrayedCount(String done) {
    return '$done of 5 prayed';
  }

  @override
  String get deedRingHint => 'Tick a prayer on Now once you have prayed it. Only you see this.';

  @override
  String deedStreak(String days) {
    return '$days days in a row with all five';
  }

  @override
  String get progressTitle => 'Your progress';

  @override
  String get progressThisWeek => 'This week';

  @override
  String get progressYear => 'The past year';

  @override
  String get progressOnTime => 'On time this month';

  @override
  String get progressBestRun => 'Longest run of all five';

  @override
  String get progressFasts => 'Fasts this year';

  @override
  String get progressQada => 'To make up (last 30 days)';

  @override
  String progressDays(String days) {
    return '$days days';
  }

  @override
  String get progressReflection =>
      '“The most beloved deeds to Allah are those done consistently, even if small.” (Bukhari, Muslim)';
}
