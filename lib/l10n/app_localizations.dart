import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('fr'),
    Locale('id'),
    Locale('tr'),
    Locale('ur'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Waqt'**
  String get appName;

  /// No description provided for @navNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get navNow;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navDuas.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get navDuas;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @momentNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get momentNight;

  /// No description provided for @momentBedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get momentBedtime;

  /// No description provided for @timePending.
  ///
  /// In en, this message translates to:
  /// **'–'**
  String get timePending;

  /// No description provided for @nowLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you praying from?'**
  String get nowLocationTitle;

  /// No description provided for @nowLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Prayer times are calculated on your phone from your location. Nothing leaves the device.'**
  String get nowLocationBody;

  /// No description provided for @todayEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your day, moment by moment'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Every window of today, from Fajr to the last third of the night, will line up here once prayer times are calculated.'**
  String get todayEmptyBody;

  /// No description provided for @duasEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Only verified sources'**
  String get duasEmptyTitle;

  /// No description provided for @duasEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'The library opens once each item has been checked against its primary source and approved by a scholar.'**
  String get duasEmptyBody;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Test mode'**
  String get settingsDeveloper;

  /// No description provided for @settingsDeveloperHint.
  ///
  /// In en, this message translates to:
  /// **'Fake clock, day jumps and the reference checker'**
  String get settingsDeveloperHint;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Waqt'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @debugTitle.
  ///
  /// In en, this message translates to:
  /// **'Test mode'**
  String get debugTitle;

  /// No description provided for @debugClock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get debugClock;

  /// No description provided for @debugClockReal.
  ///
  /// In en, this message translates to:
  /// **'Real time'**
  String get debugClockReal;

  /// No description provided for @debugClockFaked.
  ///
  /// In en, this message translates to:
  /// **'Faked'**
  String get debugClockFaked;

  /// No description provided for @debugPickDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get debugPickDate;

  /// No description provided for @debugPickTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get debugPickTime;

  /// No description provided for @debugReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get debugReset;

  /// No description provided for @debugPalette.
  ///
  /// In en, this message translates to:
  /// **'Moment palette'**
  String get debugPalette;

  /// No description provided for @debugPaletteAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get debugPaletteAuto;

  /// No description provided for @debugDirection.
  ///
  /// In en, this message translates to:
  /// **'Layout direction'**
  String get debugDirection;

  /// No description provided for @debugBuild.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get debugBuild;

  /// No description provided for @waqtMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get waqtMorning;

  /// No description provided for @nextIn.
  ///
  /// In en, this message translates to:
  /// **'{prayer} in {time}'**
  String nextIn(String prayer, String time);

  /// No description provided for @hijriDate.
  ///
  /// In en, this message translates to:
  /// **'{day} {month} {year} AH'**
  String hijriDate(String day, String month, String year);

  /// No description provided for @hijriMonth1.
  ///
  /// In en, this message translates to:
  /// **'Muharram'**
  String get hijriMonth1;

  /// No description provided for @hijriMonth2.
  ///
  /// In en, this message translates to:
  /// **'Safar'**
  String get hijriMonth2;

  /// No description provided for @hijriMonth3.
  ///
  /// In en, this message translates to:
  /// **'Rabi al-Awwal'**
  String get hijriMonth3;

  /// No description provided for @hijriMonth4.
  ///
  /// In en, this message translates to:
  /// **'Rabi al-Thani'**
  String get hijriMonth4;

  /// No description provided for @hijriMonth5.
  ///
  /// In en, this message translates to:
  /// **'Jumada al-Ula'**
  String get hijriMonth5;

  /// No description provided for @hijriMonth6.
  ///
  /// In en, this message translates to:
  /// **'Jumada al-Akhirah'**
  String get hijriMonth6;

  /// No description provided for @hijriMonth7.
  ///
  /// In en, this message translates to:
  /// **'Rajab'**
  String get hijriMonth7;

  /// No description provided for @hijriMonth8.
  ///
  /// In en, this message translates to:
  /// **'Sha\'ban'**
  String get hijriMonth8;

  /// No description provided for @hijriMonth9.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get hijriMonth9;

  /// No description provided for @hijriMonth10.
  ///
  /// In en, this message translates to:
  /// **'Shawwal'**
  String get hijriMonth10;

  /// No description provided for @hijriMonth11.
  ///
  /// In en, this message translates to:
  /// **'Dhu al-Qa\'dah'**
  String get hijriMonth11;

  /// No description provided for @hijriMonth12.
  ///
  /// In en, this message translates to:
  /// **'Dhu al-Hijjah'**
  String get hijriMonth12;

  /// No description provided for @locationUseGps.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get locationUseGps;

  /// No description provided for @locationChooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get locationChooseCity;

  /// No description provided for @locationLocating.
  ///
  /// In en, this message translates to:
  /// **'Finding you…'**
  String get locationLocating;

  /// No description provided for @gpsServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off on this phone. Turn it on, or choose a city.'**
  String get gpsServiceOff;

  /// No description provided for @gpsDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was declined. You can choose a city instead.'**
  String get gpsDenied;

  /// No description provided for @gpsDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked. Allow it in settings, or choose a city.'**
  String get gpsDeniedForever;

  /// No description provided for @gpsTimeout.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get a fix. Try again, or choose a city.'**
  String get gpsTimeout;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @settingsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get settingsLocation;

  /// No description provided for @settingsNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settingsNotSet;

  /// No description provided for @settingsUseGps.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get settingsUseGps;

  /// No description provided for @settingsGpsSource.
  ///
  /// In en, this message translates to:
  /// **'From GPS'**
  String get settingsGpsSource;

  /// No description provided for @settingsPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get settingsPrayerTimes;

  /// No description provided for @settingsMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get settingsMethod;

  /// No description provided for @settingsRegionalDefault.
  ///
  /// In en, this message translates to:
  /// **'Default for your region'**
  String get settingsRegionalDefault;

  /// No description provided for @settingsAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr time'**
  String get settingsAsr;

  /// No description provided for @asrStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get asrStandard;

  /// No description provided for @asrStandardHint.
  ///
  /// In en, this message translates to:
  /// **'Shafi\'i, Maliki, Hanbali: shadow equals object length'**
  String get asrStandardHint;

  /// No description provided for @asrHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get asrHanafi;

  /// No description provided for @asrHanafiHint.
  ///
  /// In en, this message translates to:
  /// **'Shadow twice the object length'**
  String get asrHanafiHint;

  /// No description provided for @settingsHighLat.
  ///
  /// In en, this message translates to:
  /// **'High-latitude rule'**
  String get settingsHighLat;

  /// No description provided for @highLatAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get highLatAuto;

  /// No description provided for @highLatAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Seventh of the night above 48°, middle of the night below'**
  String get highLatAutoHint;

  /// No description provided for @highLatMiddle.
  ///
  /// In en, this message translates to:
  /// **'Middle of the night'**
  String get highLatMiddle;

  /// No description provided for @highLatSeventh.
  ///
  /// In en, this message translates to:
  /// **'Seventh of the night'**
  String get highLatSeventh;

  /// No description provided for @highLatTwilight.
  ///
  /// In en, this message translates to:
  /// **'Twilight angle'**
  String get highLatTwilight;

  /// No description provided for @settingsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get settingsCalendar;

  /// No description provided for @settingsHijriAdjust.
  ///
  /// In en, this message translates to:
  /// **'Hijri date adjustment'**
  String get settingsHijriAdjust;

  /// No description provided for @hijriAdjustHint.
  ///
  /// In en, this message translates to:
  /// **'Match the moon sighting where you live'**
  String get hijriAdjustHint;

  /// No description provided for @hijriOffsetNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get hijriOffsetNone;

  /// No description provided for @hijriOffsetDays.
  ///
  /// In en, this message translates to:
  /// **'{value} d'**
  String hijriOffsetDays(String value);

  /// No description provided for @settingsAttribution.
  ///
  /// In en, this message translates to:
  /// **'City data © GeoNames, CC BY 4.0. Prayer times calculated on device.'**
  String get settingsAttribution;

  /// No description provided for @citySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a city'**
  String get citySearchHint;

  /// No description provided for @cityNoResults.
  ///
  /// In en, this message translates to:
  /// **'No cities match “{query}”'**
  String cityNoResults(String query);

  /// No description provided for @methodMwl.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get methodMwl;

  /// No description provided for @methodIsna.
  ///
  /// In en, this message translates to:
  /// **'ISNA, North America'**
  String get methodIsna;

  /// No description provided for @methodEgypt.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority of Survey'**
  String get methodEgypt;

  /// No description provided for @methodKarachi.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi'**
  String get methodKarachi;

  /// No description provided for @methodUmmAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura, Makkah'**
  String get methodUmmAlQura;

  /// No description provided for @methodDubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get methodDubai;

  /// No description provided for @methodQatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get methodQatar;

  /// No description provided for @methodKuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get methodKuwait;

  /// No description provided for @methodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore, Malaysia, Indonesia'**
  String get methodSingapore;

  /// No description provided for @methodTurkey.
  ///
  /// In en, this message translates to:
  /// **'Diyanet, Türkiye'**
  String get methodTurkey;

  /// No description provided for @methodTehran.
  ///
  /// In en, this message translates to:
  /// **'Institute of Geophysics, Tehran'**
  String get methodTehran;

  /// No description provided for @methodMoonsighting.
  ///
  /// In en, this message translates to:
  /// **'Moonsighting Committee'**
  String get methodMoonsighting;

  /// No description provided for @timesEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated. The sun doesn\'t rise or set normally here today, so times follow latitude 65°.'**
  String get timesEstimated;

  /// No description provided for @momentLastThird.
  ///
  /// In en, this message translates to:
  /// **'Last third of the night'**
  String get momentLastThird;

  /// No description provided for @momentFridayLastHour.
  ///
  /// In en, this message translates to:
  /// **'Last hour of Friday'**
  String get momentFridayLastHour;

  /// No description provided for @momentAdhanIqamah.
  ///
  /// In en, this message translates to:
  /// **'Before the {prayer} iqamah'**
  String momentAdhanIqamah(String prayer);

  /// No description provided for @momentAfterSalah.
  ///
  /// In en, this message translates to:
  /// **'After {prayer}'**
  String momentAfterSalah(String prayer);

  /// No description provided for @momentRestrictedSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sun rising'**
  String get momentRestrictedSunrise;

  /// No description provided for @momentRestrictedZawal.
  ///
  /// In en, this message translates to:
  /// **'Sun at its zenith'**
  String get momentRestrictedZawal;

  /// No description provided for @momentRestrictedSunset.
  ///
  /// In en, this message translates to:
  /// **'Sun setting'**
  String get momentRestrictedSunset;

  /// No description provided for @momentDuha.
  ///
  /// In en, this message translates to:
  /// **'Duha'**
  String get momentDuha;

  /// No description provided for @momentMorningAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Morning adhkar'**
  String get momentMorningAdhkar;

  /// No description provided for @momentEveningAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Evening adhkar'**
  String get momentEveningAdhkar;

  /// No description provided for @kindRestricted.
  ///
  /// In en, this message translates to:
  /// **'Voluntary prayer restricted'**
  String get kindRestricted;

  /// No description provided for @rightNow.
  ///
  /// In en, this message translates to:
  /// **'Right now'**
  String get rightNow;

  /// No description provided for @until.
  ///
  /// In en, this message translates to:
  /// **'until {time}'**
  String until(String time);

  /// No description provided for @comingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get comingUp;

  /// No description provided for @startsAt.
  ///
  /// In en, this message translates to:
  /// **'at {time}'**
  String startsAt(String time);

  /// No description provided for @startsIn.
  ///
  /// In en, this message translates to:
  /// **'in {time}'**
  String startsIn(String time);

  /// No description provided for @timelineNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get timelineNow;

  /// No description provided for @debugJump.
  ///
  /// In en, this message translates to:
  /// **'Jump to moment'**
  String get debugJump;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusChecked.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get statusChecked;

  /// No description provided for @draftNotice.
  ///
  /// In en, this message translates to:
  /// **'Unreviewed draft, shown in dev builds only'**
  String get draftNotice;

  /// No description provided for @collectionQuran.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an'**
  String get collectionQuran;

  /// No description provided for @collectionBukhari.
  ///
  /// In en, this message translates to:
  /// **'Bukhari'**
  String get collectionBukhari;

  /// No description provided for @collectionMuslim.
  ///
  /// In en, this message translates to:
  /// **'Muslim'**
  String get collectionMuslim;

  /// No description provided for @collectionAbudawud.
  ///
  /// In en, this message translates to:
  /// **'Abu Dawud'**
  String get collectionAbudawud;

  /// No description provided for @collectionTirmidhi.
  ///
  /// In en, this message translates to:
  /// **'Tirmidhi'**
  String get collectionTirmidhi;

  /// No description provided for @collectionNasai.
  ///
  /// In en, this message translates to:
  /// **'Nasa\'i'**
  String get collectionNasai;

  /// No description provided for @collectionIbnmajah.
  ///
  /// In en, this message translates to:
  /// **'Ibn Majah'**
  String get collectionIbnmajah;

  /// No description provided for @collectionMalik.
  ///
  /// In en, this message translates to:
  /// **'Muwatta Malik'**
  String get collectionMalik;

  /// No description provided for @collectionAhmad.
  ///
  /// In en, this message translates to:
  /// **'Ahmad'**
  String get collectionAhmad;

  /// No description provided for @collectionDarimi.
  ///
  /// In en, this message translates to:
  /// **'Darimi'**
  String get collectionDarimi;

  /// No description provided for @collectionAdab.
  ///
  /// In en, this message translates to:
  /// **'al-Adab al-Mufrad'**
  String get collectionAdab;

  /// No description provided for @collectionHakim.
  ///
  /// In en, this message translates to:
  /// **'al-Hakim'**
  String get collectionHakim;

  /// No description provided for @collectionIbnhibban.
  ///
  /// In en, this message translates to:
  /// **'Ibn Hibban'**
  String get collectionIbnhibban;

  /// No description provided for @collectionBayhaqi.
  ///
  /// In en, this message translates to:
  /// **'Bayhaqi'**
  String get collectionBayhaqi;

  /// No description provided for @collectionNasaiKubra.
  ///
  /// In en, this message translates to:
  /// **'al-Sunan al-Kubra'**
  String get collectionNasaiKubra;

  /// No description provided for @sheetSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sheetSource;

  /// No description provided for @sheetNarrator.
  ///
  /// In en, this message translates to:
  /// **'Narrated by'**
  String get sheetNarrator;

  /// No description provided for @sheetGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get sheetGrade;

  /// No description provided for @sheetGradedBy.
  ///
  /// In en, this message translates to:
  /// **'Graded by'**
  String get sheetGradedBy;

  /// No description provided for @sheetTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get sheetTranslation;

  /// No description provided for @sheetReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get sheetReview;

  /// No description provided for @sheetOpen.
  ///
  /// In en, this message translates to:
  /// **'Open on {host}'**
  String sheetOpen(String host);

  /// No description provided for @sheetTextPending.
  ///
  /// In en, this message translates to:
  /// **'The text appears here once this reference has been checked against its primary source.'**
  String get sheetTextPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Scholar approved'**
  String get statusApproved;

  /// No description provided for @gradeSahih.
  ///
  /// In en, this message translates to:
  /// **'Sahih'**
  String get gradeSahih;

  /// No description provided for @gradeHasan.
  ///
  /// In en, this message translates to:
  /// **'Hasan'**
  String get gradeHasan;

  /// No description provided for @reviewCheckedBy.
  ///
  /// In en, this message translates to:
  /// **'Checked by {name}'**
  String reviewCheckedBy(String name);

  /// No description provided for @reviewApprovedBy.
  ///
  /// In en, this message translates to:
  /// **'Approved by {name}'**
  String reviewApprovedBy(String name);

  /// No description provided for @checklistProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String checklistProgress(String done, String total);

  /// No description provided for @checklistTitleBedtime.
  ///
  /// In en, this message translates to:
  /// **'Before you sleep'**
  String get checklistTitleBedtime;

  /// No description provided for @checklistTitleJumuah.
  ///
  /// In en, this message translates to:
  /// **'Jumu\'ah'**
  String get checklistTitleJumuah;

  /// No description provided for @momentJumuah.
  ///
  /// In en, this message translates to:
  /// **'Jumu\'ah'**
  String get momentJumuah;

  /// No description provided for @librarySearch.
  ///
  /// In en, this message translates to:
  /// **'Search duas and references'**
  String get librarySearch;

  /// No description provided for @libraryNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”'**
  String libraryNoMatch(String query);

  /// No description provided for @libraryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String libraryCount(String count);

  /// No description provided for @libraryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get libraryOther;

  /// No description provided for @momentLastThirdShort.
  ///
  /// In en, this message translates to:
  /// **'Last third'**
  String get momentLastThirdShort;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'{time} · {place}'**
  String reminderBody(String time, String place);

  /// No description provided for @widgetEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Open Waqt to set your location'**
  String get widgetEmptyBody;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notifTitle;

  /// No description provided for @notifHint.
  ///
  /// In en, this message translates to:
  /// **'Adhkar, Jumu\'ah and night reminders, as you choose'**
  String get notifHint;

  /// No description provided for @notifPermission.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifPermission;

  /// No description provided for @notifAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get notifAllowed;

  /// No description provided for @notifAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get notifAllow;

  /// No description provided for @notifExact.
  ///
  /// In en, this message translates to:
  /// **'On-time delivery'**
  String get notifExact;

  /// No description provided for @notifExactHint.
  ///
  /// In en, this message translates to:
  /// **'Lets prayer reminders arrive at the exact minute'**
  String get notifExactHint;

  /// No description provided for @notifBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery optimisation'**
  String get notifBattery;

  /// No description provided for @notifBatteryOk.
  ///
  /// In en, this message translates to:
  /// **'Unrestricted'**
  String get notifBatteryOk;

  /// No description provided for @notifBatteryFix.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get notifBatteryFix;

  /// No description provided for @notifBatteryHint.
  ///
  /// In en, this message translates to:
  /// **'Some phones stop reminders in the background. Set Waqt to Unrestricted.'**
  String get notifBatteryHint;

  /// No description provided for @notifBatteryHintOem.
  ///
  /// In en, this message translates to:
  /// **'{maker} phones often stop reminders in the background. Set Waqt to Unrestricted.'**
  String notifBatteryHintOem(String maker);

  /// No description provided for @notifPrayers.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get notifPrayers;

  /// No description provided for @notifMoments.
  ///
  /// In en, this message translates to:
  /// **'Moments'**
  String get notifMoments;

  /// No description provided for @notifSound.
  ///
  /// In en, this message translates to:
  /// **'Play sound'**
  String get notifSound;

  /// No description provided for @notifSoundHint.
  ///
  /// In en, this message translates to:
  /// **'Off keeps every reminder silent'**
  String get notifSoundHint;

  /// No description provided for @notifScheduled.
  ///
  /// In en, this message translates to:
  /// **'{count} reminders scheduled until {date}'**
  String notifScheduled(String count, String date);

  /// No description provided for @notifNone.
  ///
  /// In en, this message translates to:
  /// **'No reminders scheduled'**
  String get notifNone;

  /// No description provided for @notifStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get notifStatus;

  /// No description provided for @setupCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminders'**
  String get setupCardTitle;

  /// No description provided for @setupCardBody.
  ///
  /// In en, this message translates to:
  /// **'A quiet nudge at each prayer time. You choose which, and nothing leaves your phone.'**
  String get setupCardBody;

  /// No description provided for @setupCardAction.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get setupCardAction;

  /// No description provided for @setupCardDismiss.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get setupCardDismiss;

  /// No description provided for @momentLaylatAlQadr.
  ///
  /// In en, this message translates to:
  /// **'An odd night of the last ten'**
  String get momentLaylatAlQadr;

  /// No description provided for @momentSuhoor.
  ///
  /// In en, this message translates to:
  /// **'Suhoor'**
  String get momentSuhoor;

  /// No description provided for @momentIftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get momentIftar;

  /// No description provided for @occEidAlFitr.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Fitr'**
  String get occEidAlFitr;

  /// No description provided for @occEidAlAdha.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Adha'**
  String get occEidAlAdha;

  /// No description provided for @occArafah.
  ///
  /// In en, this message translates to:
  /// **'Day of Arafah'**
  String get occArafah;

  /// No description provided for @occTashreeq.
  ///
  /// In en, this message translates to:
  /// **'Days of Tashreeq'**
  String get occTashreeq;

  /// No description provided for @occAshura.
  ///
  /// In en, this message translates to:
  /// **'Ashura'**
  String get occAshura;

  /// No description provided for @occTasua.
  ///
  /// In en, this message translates to:
  /// **'Tasu\'a'**
  String get occTasua;

  /// No description provided for @occLastTen.
  ///
  /// In en, this message translates to:
  /// **'Last ten nights'**
  String get occLastTen;

  /// No description provided for @occRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan {day}'**
  String occRamadan(String day);

  /// No description provided for @occFirstTen.
  ///
  /// In en, this message translates to:
  /// **'First ten of Dhul Hijjah'**
  String get occFirstTen;

  /// No description provided for @occBid.
  ///
  /// In en, this message translates to:
  /// **'Ayyam al-Bid'**
  String get occBid;

  /// No description provided for @occMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday fast'**
  String get occMonday;

  /// No description provided for @occThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday fast'**
  String get occThursday;

  /// No description provided for @counterTitle.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counterTitle;

  /// No description provided for @counterTap.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to count'**
  String get counterTap;

  /// No description provided for @counterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get counterReset;

  /// No description provided for @counterRound.
  ///
  /// In en, this message translates to:
  /// **'Round {n}'**
  String counterRound(String n);

  /// No description provided for @counterTarget.
  ///
  /// In en, this message translates to:
  /// **'Beads per round'**
  String get counterTarget;

  /// No description provided for @counterOpen.
  ///
  /// In en, this message translates to:
  /// **'Open counter'**
  String get counterOpen;

  /// No description provided for @reportContent.
  ///
  /// In en, this message translates to:
  /// **'Report an issue with this text'**
  String get reportContent;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportProblem;

  /// No description provided for @reportProblemHint.
  ///
  /// In en, this message translates to:
  /// **'Opens an email draft. You see everything before it is sent.'**
  String get reportProblemHint;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Everything is calculated on this phone. Waqt has no accounts, ads or analytics.'**
  String get privacyBody;

  /// No description provided for @placeTime.
  ///
  /// In en, this message translates to:
  /// **'{city} time'**
  String placeTime(String city);

  /// No description provided for @testModeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Test mode is on. Find it at the bottom of Settings.'**
  String get testModeUnlocked;

  /// No description provided for @debugJumpDay.
  ///
  /// In en, this message translates to:
  /// **'Jump to a day'**
  String get debugJumpDay;

  /// No description provided for @debugNextFriday.
  ///
  /// In en, this message translates to:
  /// **'Next Friday'**
  String get debugNextFriday;

  /// No description provided for @debugContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get debugContent;

  /// No description provided for @debugShowUnchecked.
  ///
  /// In en, this message translates to:
  /// **'Show unchecked content'**
  String get debugShowUnchecked;

  /// No description provided for @debugShowUncheckedHint.
  ///
  /// In en, this message translates to:
  /// **'On this phone only. Unchecked items are marked as drafts.'**
  String get debugShowUncheckedHint;

  /// No description provided for @debugLock.
  ///
  /// In en, this message translates to:
  /// **'Turn off test mode'**
  String get debugLock;

  /// No description provided for @checkerTitle.
  ///
  /// In en, this message translates to:
  /// **'Check references'**
  String get checkerTitle;

  /// No description provided for @checkerHint.
  ///
  /// In en, this message translates to:
  /// **'Open each reference at its source and confirm it'**
  String get checkerHint;

  /// No description provided for @checkerProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} checked'**
  String checkerProgress(int done, int total);

  /// No description provided for @checkerOpen.
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get checkerOpen;

  /// No description provided for @checkerCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get checkerCorrect;

  /// No description provided for @checkerWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get checkerWrong;

  /// No description provided for @checkerWrongHint.
  ///
  /// In en, this message translates to:
  /// **'What is wrong, and the correct reference if you know it'**
  String get checkerWrongHint;

  /// No description provided for @checkerSend.
  ///
  /// In en, this message translates to:
  /// **'Email results'**
  String get checkerSend;

  /// No description provided for @windowLeft.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String windowLeft(String time);

  /// No description provided for @windowPreferred.
  ///
  /// In en, this message translates to:
  /// **'best before {time}'**
  String windowPreferred(String time);

  /// No description provided for @durHm.
  ///
  /// In en, this message translates to:
  /// **'{h} h {m} min'**
  String durHm(String h, String m);

  /// No description provided for @durM.
  ///
  /// In en, this message translates to:
  /// **'{m} min'**
  String durM(String m);

  /// No description provided for @counterChoose.
  ///
  /// In en, this message translates to:
  /// **'Change dhikr'**
  String get counterChoose;

  /// No description provided for @counterStep.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String counterStep(String n, String total);

  /// No description provided for @counterFree.
  ///
  /// In en, this message translates to:
  /// **'Free count'**
  String get counterFree;

  /// No description provided for @counterFreeHint.
  ///
  /// In en, this message translates to:
  /// **'Count anything, with your own target'**
  String get counterFreeHint;

  /// No description provided for @counterAfterSalah.
  ///
  /// In en, this message translates to:
  /// **'After salah: 33 · 33 · 34'**
  String get counterAfterSalah;

  /// No description provided for @counterHaptics.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on each count'**
  String get counterHaptics;

  /// No description provided for @counterAfterSalahName.
  ///
  /// In en, this message translates to:
  /// **'After salah'**
  String get counterAfterSalahName;

  /// No description provided for @librarySearchAll.
  ///
  /// In en, this message translates to:
  /// **'Search hadith and duas'**
  String get librarySearchAll;

  /// No description provided for @scopeDuas.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get scopeDuas;

  /// No description provided for @scopeHadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get scopeHadith;

  /// No description provided for @librarySituations.
  ///
  /// In en, this message translates to:
  /// **'Every situation'**
  String get librarySituations;

  /// No description provided for @libraryForNow.
  ///
  /// In en, this message translates to:
  /// **'For now'**
  String get libraryForNow;

  /// No description provided for @duaCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dua} other{{count} duas}}'**
  String duaCount(int count);

  /// No description provided for @libraryPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing hadith search. This happens once.'**
  String get libraryPreparing;

  /// No description provided for @libraryRefine.
  ///
  /// In en, this message translates to:
  /// **'Showing the first 60. Add a word to narrow it.'**
  String get libraryRefine;

  /// No description provided for @sourceHisn.
  ///
  /// In en, this message translates to:
  /// **'Hisn al-Muslim by Sa\'id bin Ali bin Wahf al-Qahtani. Text, transliteration and translation as published on sunnah.com, via open-hadith-data.'**
  String get sourceHisn;

  /// No description provided for @sourceHadith.
  ///
  /// In en, this message translates to:
  /// **'Arabic and English as published on sunnah.com, via open-hadith-data. Grades as given by the source.'**
  String get sourceHadith;

  /// No description provided for @hisnNumber.
  ///
  /// In en, this message translates to:
  /// **'Hisn al-Muslim {n}'**
  String hisnNumber(String n);

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyText;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get openSource;

  /// No description provided for @readingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading size'**
  String get readingTitle;

  /// No description provided for @readingHint.
  ///
  /// In en, this message translates to:
  /// **'Arabic, transliteration and meaning, each on its own'**
  String get readingHint;

  /// No description provided for @readingArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get readingArabic;

  /// No description provided for @readingTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Transliteration'**
  String get readingTransliteration;

  /// No description provided for @readingMeaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get readingMeaning;

  /// No description provided for @stripLeft.
  ///
  /// In en, this message translates to:
  /// **'{time} until {prayer}'**
  String stripLeft(String time, String prayer);

  /// No description provided for @dayGuideToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sunnah'**
  String get dayGuideToday;

  /// No description provided for @fastToday.
  ///
  /// In en, this message translates to:
  /// **'Sunnah fast today · {day}'**
  String fastToday(String day);

  /// No description provided for @fastTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Fast tomorrow · {day}'**
  String fastTomorrow(String day);

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarLegendGuide.
  ///
  /// In en, this message translates to:
  /// **'Has a guide'**
  String get calendarLegendGuide;

  /// No description provided for @calendarLegendFast.
  ///
  /// In en, this message translates to:
  /// **'Sunnah fast'**
  String get calendarLegendFast;

  /// No description provided for @calendarNote.
  ///
  /// In en, this message translates to:
  /// **'Dates follow Umm al-Qura with your Hijri adjustment. On the 29th of Shaban, Ramadan and Dhul Qadah, Home asks whether the new moon was seen.'**
  String get calendarNote;

  /// No description provided for @sightingTitle.
  ///
  /// In en, this message translates to:
  /// **'Was the new moon of {month} seen where you are?'**
  String sightingTitle(String month);

  /// No description provided for @sightingBody.
  ///
  /// In en, this message translates to:
  /// **'Your answer moves the calendar so Ramadan, Eid and Arafah fall on the days your community keeps.'**
  String get sightingBody;

  /// No description provided for @sightingSeen.
  ///
  /// In en, this message translates to:
  /// **'Seen: {month} begins'**
  String sightingSeen(String month);

  /// No description provided for @sightingNotSeen.
  ///
  /// In en, this message translates to:
  /// **'Not seen: 30 days'**
  String get sightingNotSeen;

  /// No description provided for @sightingUnsure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get sightingUnsure;

  /// No description provided for @ramadanSuhoor.
  ///
  /// In en, this message translates to:
  /// **'Suhoor ends'**
  String get ramadanSuhoor;

  /// No description provided for @ramadanIftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get ramadanIftar;

  /// No description provided for @ramadanIn.
  ///
  /// In en, this message translates to:
  /// **'in {time}'**
  String ramadanIn(String time);

  /// No description provided for @ramadanDone.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get ramadanDone;

  /// No description provided for @announceTitle.
  ///
  /// In en, this message translates to:
  /// **'Tonight decides {month}'**
  String announceTitle(String month);

  /// No description provided for @announceBegins.
  ///
  /// In en, this message translates to:
  /// **'By the {authority}, {month} begins tomorrow.'**
  String announceBegins(String month, String authority);

  /// No description provided for @announceThirty.
  ///
  /// In en, this message translates to:
  /// **'By the {authority}, {month} completes 30 days: tomorrow is the 30th.'**
  String announceThirty(String month, String authority);

  /// No description provided for @announceOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline: showing the last downloaded dates. Waqt will check again when you are connected.'**
  String get announceOffline;

  /// No description provided for @announceChecking.
  ///
  /// In en, this message translates to:
  /// **'Waqt checks for the announcement every 30 minutes tonight. Last checked {time}.'**
  String announceChecking(String time);

  /// No description provided for @authoritySaudi.
  ///
  /// In en, this message translates to:
  /// **'Saudi High Judiciary Council'**
  String get authoritySaudi;

  /// No description provided for @authorityDiyanet.
  ///
  /// In en, this message translates to:
  /// **'Diyanet (Türkiye)'**
  String get authorityDiyanet;

  /// No description provided for @authorityLocal.
  ///
  /// In en, this message translates to:
  /// **'Local moon sighting'**
  String get authorityLocal;

  /// No description provided for @authoritySaudiHint.
  ///
  /// In en, this message translates to:
  /// **'Announced sightings, updated online'**
  String get authoritySaudiHint;

  /// No description provided for @authorityDiyanetHint.
  ///
  /// In en, this message translates to:
  /// **'Türkiye\'s official calendar, updated online'**
  String get authorityDiyanetHint;

  /// No description provided for @authorityLocalHint.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura; on the 29th you say whether the moon was seen'**
  String get authorityLocalHint;

  /// No description provided for @calendarSourceLine.
  ///
  /// In en, this message translates to:
  /// **'{authority} · checked {time}'**
  String calendarSourceLine(String authority, String time);

  /// No description provided for @calendarSourceLocal.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura with your adjustment. On the 29th of Shaban, Ramadan and Dhul Qadah, Home asks whether the new moon was seen.'**
  String get calendarSourceLocal;

  /// No description provided for @announceUnknown.
  ///
  /// In en, this message translates to:
  /// **'The announcement has not reached Waqt yet. If the crescent is seen tonight, {month} begins tomorrow; if not, this month completes 30 days.'**
  String announceUnknown(String month);

  /// No description provided for @adjustTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust times'**
  String get adjustTitle;

  /// No description provided for @adjustRowHint.
  ///
  /// In en, this message translates to:
  /// **'Match your local timetable or mosque'**
  String get adjustRowHint;

  /// No description provided for @adjustNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get adjustNone;

  /// No description provided for @adjustSome.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} times}}'**
  String adjustSome(int count);

  /// No description provided for @adjustHint.
  ///
  /// In en, this message translates to:
  /// **'Times are calculated for your exact position. If your local timetable (for example your country\'s Islamic Foundation, or your mosque) differs by a minute or two, match it here.'**
  String get adjustHint;

  /// No description provided for @adjustNote.
  ///
  /// In en, this message translates to:
  /// **'Suhoor ends at Fajr and iftar is at Maghrib, so adjusting those moves suhoor and iftar too. Reminders and the widget follow.'**
  String get adjustNote;

  /// No description provided for @adjustEarlier.
  ///
  /// In en, this message translates to:
  /// **'1 minute earlier'**
  String get adjustEarlier;

  /// No description provided for @adjustLater.
  ///
  /// In en, this message translates to:
  /// **'1 minute later'**
  String get adjustLater;

  /// No description provided for @momentTaraweeh.
  ///
  /// In en, this message translates to:
  /// **'Taraweeh'**
  String get momentTaraweeh;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all {count}'**
  String showAll(int count);

  /// No description provided for @hadithUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Hadith search isn\'t available here. It works in the Android app.'**
  String get hadithUnavailable;

  /// No description provided for @hadithLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Hadith library'**
  String get hadithLibraryTitle;

  /// No description provided for @hadithLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'HadeethEnc\'s encyclopedia in your language: authentic hadiths with the Arabic, grade and explanation, searchable offline. Downloaded once.'**
  String get hadithLibraryBody;

  /// No description provided for @hadithLibraryDownload.
  ///
  /// In en, this message translates to:
  /// **'Download ({mb} MB)'**
  String hadithLibraryDownload(String mb);

  /// No description provided for @hadithLibraryProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String hadithLibraryProgress(int percent);

  /// No description provided for @hadithLibraryFailed.
  ///
  /// In en, this message translates to:
  /// **'The download didn\'t finish. Check your connection.'**
  String get hadithLibraryFailed;

  /// No description provided for @hadithLibraryRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get hadithLibraryRetry;

  /// No description provided for @hadithLibraryNote.
  ///
  /// In en, this message translates to:
  /// **'From HadeethEnc.com, shown unchanged. Home, the checklists and the counter work without it.'**
  String get hadithLibraryNote;

  /// No description provided for @counterToday.
  ///
  /// In en, this message translates to:
  /// **'Today {count}'**
  String counterToday(String count);

  /// No description provided for @counterTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Said today'**
  String get counterTodayTitle;

  /// No description provided for @counterTodayAll.
  ///
  /// In en, this message translates to:
  /// **'All dhikr'**
  String get counterTodayAll;

  /// No description provided for @counterResetRound.
  ///
  /// In en, this message translates to:
  /// **'Restart this round'**
  String get counterResetRound;

  /// No description provided for @debugScenarios.
  ///
  /// In en, this message translates to:
  /// **'Scenarios'**
  String get debugScenarios;

  /// No description provided for @debugState.
  ///
  /// In en, this message translates to:
  /// **'What the app sees'**
  String get debugState;

  /// No description provided for @debugData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get debugData;

  /// No description provided for @debugRefreshCalendar.
  ///
  /// In en, this message translates to:
  /// **'Check the calendar now'**
  String get debugRefreshCalendar;

  /// No description provided for @debugClearTicks.
  ///
  /// In en, this message translates to:
  /// **'Clear today\'s ticks'**
  String get debugClearTicks;

  /// No description provided for @debugClearCounter.
  ///
  /// In en, this message translates to:
  /// **'Clear the counter'**
  String get debugClearCounter;

  /// No description provided for @debugClearSightings.
  ///
  /// In en, this message translates to:
  /// **'Forget moon-sighting answers'**
  String get debugClearSightings;

  /// No description provided for @debugRemoveHadith.
  ///
  /// In en, this message translates to:
  /// **'Remove the hadith library'**
  String get debugRemoveHadith;

  /// No description provided for @debugDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get debugDone;

  /// No description provided for @debugScEveRamadan.
  ///
  /// In en, this message translates to:
  /// **'29 Shaban evening'**
  String get debugScEveRamadan;

  /// No description provided for @debugScSuhoor.
  ///
  /// In en, this message translates to:
  /// **'Ramadan suhoor'**
  String get debugScSuhoor;

  /// No description provided for @debugScIftar.
  ///
  /// In en, this message translates to:
  /// **'Ramadan iftar'**
  String get debugScIftar;

  /// No description provided for @debugScTaraweeh.
  ///
  /// In en, this message translates to:
  /// **'Taraweeh'**
  String get debugScTaraweeh;

  /// No description provided for @debugScQadr.
  ///
  /// In en, this message translates to:
  /// **'27th night, last third'**
  String get debugScQadr;

  /// No description provided for @debugScEveEid.
  ///
  /// In en, this message translates to:
  /// **'29 Ramadan evening'**
  String get debugScEveEid;

  /// No description provided for @debugScEid.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Fitr morning'**
  String get debugScEid;

  /// No description provided for @debugScArafah.
  ///
  /// In en, this message translates to:
  /// **'Arafah'**
  String get debugScArafah;

  /// No description provided for @debugScAshura.
  ///
  /// In en, this message translates to:
  /// **'Ashura'**
  String get debugScAshura;

  /// No description provided for @counterAddOwn.
  ///
  /// In en, this message translates to:
  /// **'Add your own'**
  String get counterAddOwn;

  /// No description provided for @counterOwnName.
  ///
  /// In en, this message translates to:
  /// **'What you\'ll say'**
  String get counterOwnName;

  /// No description provided for @counterOwnArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic (optional)'**
  String get counterOwnArabic;

  /// No description provided for @counterOwnTarget.
  ///
  /// In en, this message translates to:
  /// **'How many times'**
  String get counterOwnTarget;

  /// No description provided for @counterSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get counterSave;

  /// No description provided for @counterRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get counterRemove;

  /// No description provided for @counterSectionReward.
  ///
  /// In en, this message translates to:
  /// **'With a promised reward'**
  String get counterSectionReward;

  /// No description provided for @counterSectionYours.
  ///
  /// In en, this message translates to:
  /// **'Your own'**
  String get counterSectionYours;

  /// No description provided for @sheetExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get sheetExplanation;

  /// No description provided for @sheetEnglishOriginal.
  ///
  /// In en, this message translates to:
  /// **'English (sunnah.com)'**
  String get sheetEnglishOriginal;

  /// No description provided for @sourceHadeethEnc.
  ///
  /// In en, this message translates to:
  /// **'Translation and explanation: HadeethEnc.com, shown unchanged (retrieved {date}).'**
  String sourceHadeethEnc(String date);

  /// No description provided for @openHadeethEnc.
  ///
  /// In en, this message translates to:
  /// **'HadeethEnc'**
  String get openHadeethEnc;

  /// No description provided for @heNotTranslated.
  ///
  /// In en, this message translates to:
  /// **'HadeethEnc hasn\'t translated this hadith into {language} yet, so the Arabic is shown.'**
  String heNotTranslated(String language);

  /// No description provided for @libraryAllTopics.
  ///
  /// In en, this message translates to:
  /// **'All topics'**
  String get libraryAllTopics;

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qiblaTitle;

  /// No description provided for @qiblaFrom.
  ///
  /// In en, this message translates to:
  /// **'From {city}'**
  String qiblaFrom(String city);

  /// No description provided for @qiblaFacing.
  ///
  /// In en, this message translates to:
  /// **'Facing the Qibla'**
  String get qiblaFacing;

  /// No description provided for @qiblaTurnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn right'**
  String get qiblaTurnRight;

  /// No description provided for @qiblaTurnLeft.
  ///
  /// In en, this message translates to:
  /// **'Turn left'**
  String get qiblaTurnLeft;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get qiblaDirection;

  /// No description provided for @qiblaBearing.
  ///
  /// In en, this message translates to:
  /// **'{deg}° from north'**
  String qiblaBearing(String deg);

  /// No description provided for @qiblaDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance to the Kaaba'**
  String get qiblaDistance;

  /// No description provided for @qiblaKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String qiblaKm(String km);

  /// No description provided for @qiblaHoldFlat.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone flat'**
  String get qiblaHoldFlat;

  /// No description provided for @qiblaCalibrate.
  ///
  /// In en, this message translates to:
  /// **'If the direction drifts, move your phone in a figure eight, away from metal and magnets.'**
  String get qiblaCalibrate;

  /// No description provided for @qiblaNoCompass.
  ///
  /// In en, this message translates to:
  /// **'No compass on this device. Face {deg}° from north using a landmark or the sun.'**
  String qiblaNoCompass(String deg);

  /// No description provided for @qiblaNoPlace.
  ///
  /// In en, this message translates to:
  /// **'Choose a city to find the Qibla.'**
  String get qiblaNoPlace;

  /// No description provided for @qiblaNorthShort.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get qiblaNorthShort;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'bn', 'en', 'fr', 'id', 'tr', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
