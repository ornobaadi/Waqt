import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('ar'), Locale('en')];

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
  /// **'Developer'**
  String get settingsDeveloper;

  /// No description provided for @settingsDeveloperHint.
  ///
  /// In en, this message translates to:
  /// **'Fake clock and moment palettes'**
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
  /// **'Developer'**
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
