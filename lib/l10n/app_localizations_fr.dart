// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Waqt';

  @override
  String get navNow => 'Maintenant';

  @override
  String get navToday => 'Aujourd\'hui';

  @override
  String get navDuas => 'Invocations';

  @override
  String get navSettings => 'Réglages';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Lever du soleil';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Icha';

  @override
  String get momentNight => 'Nuit';

  @override
  String get momentBedtime => 'Coucher';

  @override
  String get timePending => '–';

  @override
  String get nowLocationTitle => 'D\'où priez-vous ?';

  @override
  String get nowLocationBody =>
      'Les horaires de prière sont calculés sur votre téléphone à partir de votre position. Rien ne quitte l\'appareil.';

  @override
  String get todayEmptyTitle => 'Votre journée, moment par moment';

  @override
  String get todayEmptyBody =>
      'Chaque moment de la journée, du Fajr au dernier tiers de la nuit, s\'affichera ici une fois les horaires calculés.';

  @override
  String get duasEmptyTitle => 'Uniquement des sources vérifiées';

  @override
  String get duasEmptyBody =>
      'La bibliothèque ouvrira lorsque chaque texte aura été vérifié sur sa source et approuvé par un savant.';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Langue de l\'appareil';

  @override
  String get settingsDeveloper => 'Test mode';

  @override
  String get settingsDeveloperHint => 'Fake clock, day jumps and the reference checker';

  @override
  String get settingsAbout => 'À propos de Waqt';

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
  String get waqtMorning => 'Matinée';

  @override
  String nextIn(String prayer, String time) {
    return '$prayer dans $time';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year H';
  }

  @override
  String get hijriMonth1 => 'Mouharram';

  @override
  String get hijriMonth2 => 'Safar';

  @override
  String get hijriMonth3 => 'Rabi al-Awwal';

  @override
  String get hijriMonth4 => 'Rabi al-Thani';

  @override
  String get hijriMonth5 => 'Joumada al-Oula';

  @override
  String get hijriMonth6 => 'Joumada al-Akhira';

  @override
  String get hijriMonth7 => 'Rajab';

  @override
  String get hijriMonth8 => 'Chaabane';

  @override
  String get hijriMonth9 => 'Ramadan';

  @override
  String get hijriMonth10 => 'Chawwal';

  @override
  String get hijriMonth11 => 'Dhou al-Qi\'da';

  @override
  String get hijriMonth12 => 'Dhou al-Hijja';

  @override
  String get locationUseGps => 'Utiliser ma position';

  @override
  String get locationChooseCity => 'Choisir une ville';

  @override
  String get locationLocating => 'Localisation…';

  @override
  String get gpsServiceOff => 'La localisation est désactivée sur ce téléphone. Activez-la ou choisissez une ville.';

  @override
  String get gpsDenied => 'L\'autorisation de localisation a été refusée. Vous pouvez choisir une ville.';

  @override
  String get gpsDeniedForever =>
      'L\'autorisation de localisation est bloquée. Autorisez-la dans les réglages ou choisissez une ville.';

  @override
  String get gpsTimeout => 'Position introuvable. Réessayez ou choisissez une ville.';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String get settingsLocation => 'Lieu';

  @override
  String get settingsNotSet => 'Non défini';

  @override
  String get settingsUseGps => 'Utiliser la position actuelle';

  @override
  String get settingsGpsSource => 'Par GPS';

  @override
  String get settingsPrayerTimes => 'Horaires de prière';

  @override
  String get settingsMethod => 'Méthode de calcul';

  @override
  String get settingsRegionalDefault => 'Par défaut pour votre région';

  @override
  String get settingsAsr => 'Heure de l\'Asr';

  @override
  String get asrStandard => 'Majorité';

  @override
  String get asrStandardHint => 'Chafiite, malikite, hanbalite : ombre égale à l\'objet';

  @override
  String get asrHanafi => 'Hanafite';

  @override
  String get asrHanafiHint => 'Ombre égale au double de l\'objet';

  @override
  String get settingsHighLat => 'Règle des hautes latitudes';

  @override
  String get highLatAuto => 'Automatique';

  @override
  String get highLatAutoHint => 'Septième de la nuit au-delà de 48°, milieu de la nuit en deçà';

  @override
  String get highLatMiddle => 'Milieu de la nuit';

  @override
  String get highLatSeventh => 'Septième de la nuit';

  @override
  String get highLatTwilight => 'Angle du crépuscule';

  @override
  String get settingsCalendar => 'Calendrier';

  @override
  String get settingsHijriAdjust => 'Ajustement de la date hégirienne';

  @override
  String get hijriAdjustHint => 'Pour suivre l\'observation du croissant chez vous';

  @override
  String get hijriOffsetNone => 'Aucun';

  @override
  String hijriOffsetDays(String value) {
    return '$value j';
  }

  @override
  String get settingsAttribution => 'Données des villes © GeoNames, CC BY 4.0. Horaires calculés sur l\'appareil.';

  @override
  String get citySearchHint => 'Rechercher une ville';

  @override
  String cityNoResults(String query) {
    return 'Aucune ville ne correspond à « $query »';
  }

  @override
  String get methodMwl => 'Ligue islamique mondiale';

  @override
  String get methodIsna => 'ISNA, Amérique du Nord';

  @override
  String get methodEgypt => 'Autorité générale égyptienne d\'arpentage';

  @override
  String get methodKarachi => 'Université des sciences islamiques, Karachi';

  @override
  String get methodUmmAlQura => 'Umm al-Qura, La Mecque';

  @override
  String get methodDubai => 'Dubaï';

  @override
  String get methodQatar => 'Qatar';

  @override
  String get methodKuwait => 'Koweït';

  @override
  String get methodSingapore => 'Singapour, Malaisie, Indonésie';

  @override
  String get methodTurkey => 'Diyanet, Turquie';

  @override
  String get methodTehran => 'Institut de géophysique, Téhéran';

  @override
  String get methodMoonsighting => 'Moonsighting Committee';

  @override
  String get timesEstimated =>
      'Estimation. Le soleil ne se lève ou ne se couche pas normalement ici aujourd\'hui : les horaires suivent la latitude 65°.';

  @override
  String get momentLastThird => 'Dernier tiers de la nuit';

  @override
  String get momentFridayLastHour => 'Dernière heure du vendredi';

  @override
  String momentAdhanIqamah(String prayer) {
    return 'Avant l\'iqama de $prayer';
  }

  @override
  String momentAfterSalah(String prayer) {
    return 'Après $prayer';
  }

  @override
  String get momentRestrictedSunrise => 'Soleil levant';

  @override
  String get momentRestrictedZawal => 'Soleil au zénith';

  @override
  String get momentRestrictedSunset => 'Soleil couchant';

  @override
  String get momentDuha => 'Duha';

  @override
  String get momentMorningAdhkar => 'Adhkar du matin';

  @override
  String get momentEveningAdhkar => 'Adhkar du soir';

  @override
  String get kindRestricted => 'Prière surérogatoire déconseillée';

  @override
  String get rightNow => 'En ce moment';

  @override
  String until(String time) {
    return 'jusqu\'à $time';
  }

  @override
  String get comingUp => 'À venir';

  @override
  String startsAt(String time) {
    return 'à $time';
  }

  @override
  String startsIn(String time) {
    return 'dans $time';
  }

  @override
  String get timelineNow => 'Maintenant';

  @override
  String get debugJump => 'Jump to moment';

  @override
  String get statusDraft => 'Brouillon';

  @override
  String get statusChecked => 'Vérifié';

  @override
  String get draftNotice => 'Brouillon non vérifié, visible uniquement en version de développement';

  @override
  String get collectionQuran => 'Coran';

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
  String get sheetNarrator => 'Rapporté par';

  @override
  String get sheetGrade => 'Degré';

  @override
  String get sheetGradedBy => 'Jugé par';

  @override
  String get sheetTranslation => 'Traduction';

  @override
  String get sheetReview => 'Vérification';

  @override
  String sheetOpen(String host) {
    return 'Ouvrir sur $host';
  }

  @override
  String get sheetTextPending => 'Le texte apparaîtra ici une fois cette référence vérifiée sur sa source.';

  @override
  String get statusApproved => 'Approuvé par un savant';

  @override
  String get gradeSahih => 'Sahih';

  @override
  String get gradeHasan => 'Hasan';

  @override
  String reviewCheckedBy(String name) {
    return 'Vérifié par $name';
  }

  @override
  String reviewApprovedBy(String name) {
    return 'Approuvé par $name';
  }

  @override
  String checklistProgress(String done, String total) {
    return '$done sur $total';
  }

  @override
  String get checklistTitleBedtime => 'Avant de dormir';

  @override
  String get checklistTitleJumuah => 'Jumu\'a';

  @override
  String get momentJumuah => 'Jumu\'a';

  @override
  String get librarySearch => 'Rechercher invocations et références';

  @override
  String libraryNoMatch(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String libraryCount(String count) {
    return '$count éléments';
  }

  @override
  String get libraryOther => 'Autres';

  @override
  String get momentLastThirdShort => 'Dernier tiers';

  @override
  String reminderBody(String time, String place) {
    return '$time · $place';
  }

  @override
  String get widgetEmptyBody => 'Ouvrez Waqt pour choisir votre lieu';

  @override
  String get notifTitle => 'Rappels';

  @override
  String get notifHint => 'Arafat, Achoura, le vendredi, le Ramadan et plus';

  @override
  String get notifPermission => 'Notifications';

  @override
  String get notifAllowed => 'Autorisé';

  @override
  String get notifAllow => 'Autoriser';

  @override
  String get notifExact => 'Ponctualité';

  @override
  String get notifExactHint => 'Pour que les rappels de prière arrivent à la minute près';

  @override
  String get notifBattery => 'Optimisation de la batterie';

  @override
  String get notifBatteryOk => 'Sans restriction';

  @override
  String get notifBatteryFix => 'Ouvrir les réglages';

  @override
  String get notifBatteryHint =>
      'Certains téléphones bloquent les rappels en arrière-plan. Réglez Waqt sur « Sans restriction ».';

  @override
  String notifBatteryHintOem(String maker) {
    return 'Les téléphones $maker bloquent souvent les rappels en arrière-plan. Réglez Waqt sur « Sans restriction ».';
  }

  @override
  String get notifPrayers => 'Horaires de prière';

  @override
  String get notifMoments => 'Moments';

  @override
  String get notifSound => 'Son';

  @override
  String get notifSoundHint => 'Désactivé, tous les rappels restent silencieux';

  @override
  String notifScheduled(String count, String date) {
    return '$count rappels programmés jusqu\'au $date';
  }

  @override
  String get notifNone => 'Aucun rappel programmé';

  @override
  String get notifStatus => 'État';

  @override
  String get setupCardTitle => 'Laisse Waqt te le rappeler';

  @override
  String get setupCardBody =>
      'La veille d\'Arafat, d\'Achoura ou de l\'Aïd, et chaque vendredi : quoi faire, et pourquoi.';

  @override
  String get setupCardAction => 'Activer';

  @override
  String get setupCardDismiss => 'Plus tard';

  @override
  String get momentLaylatAlQadr => 'Une nuit impaire des dix dernières';

  @override
  String get momentSuhoor => 'Suhour';

  @override
  String get momentIftar => 'Iftar';

  @override
  String get occEidAlFitr => 'Aïd al-Fitr';

  @override
  String get occEidAlAdha => 'Aïd al-Adha';

  @override
  String get occArafah => 'Jour d\'Arafat';

  @override
  String get occTashreeq => 'Jours de Tachriq';

  @override
  String get occAshura => 'Achoura';

  @override
  String get occTasua => 'Tasou\'a';

  @override
  String get occLastTen => 'Dix dernières nuits';

  @override
  String occRamadan(String day) {
    return 'Ramadan $day';
  }

  @override
  String get occFirstTen => 'Dix premiers jours de Dhou al-Hijja';

  @override
  String get occBid => 'Jours blancs';

  @override
  String get occMonday => 'Jeûne du lundi';

  @override
  String get occThursday => 'Jeûne du jeudi';

  @override
  String get counterTitle => 'Compteur';

  @override
  String get counterTap => 'Touchez n\'importe où pour compter';

  @override
  String get counterReset => 'Remettre à zéro';

  @override
  String counterRound(String n) {
    return 'Tour $n';
  }

  @override
  String get counterTarget => 'Grains par tour';

  @override
  String get counterOpen => 'Compteur de tasbih';

  @override
  String get reportContent => 'Signaler un problème dans ce texte';

  @override
  String get reportProblem => 'Signaler un problème';

  @override
  String get reportProblemHint => 'Ouvre un brouillon d\'e-mail. Vous voyez tout avant l\'envoi.';

  @override
  String get privacyTitle => 'Confidentialité';

  @override
  String get privacyBody => 'Tout est calculé sur ce téléphone. Waqt n\'a ni compte, ni publicité, ni statistiques.';

  @override
  String placeTime(String city) {
    return 'Heure de $city';
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
    return '$time restantes';
  }

  @override
  String windowPreferred(String time) {
    return 'de préférence avant $time';
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
  String get counterChoose => 'Changer de dhikr';

  @override
  String counterStep(String n, String total) {
    return 'Étape $n sur $total';
  }

  @override
  String get counterFree => 'Comptage libre';

  @override
  String get counterFreeHint => 'Comptez ce que vous voulez, avec votre objectif';

  @override
  String get counterAfterSalah => 'Après la prière : 33 · 33 · 34';

  @override
  String get counterHaptics => 'Vibrer à chaque compte';

  @override
  String get counterAfterSalahName => 'Après la prière';

  @override
  String get librarySearchAll => 'Rechercher hadiths et invocations';

  @override
  String get scopeDuas => 'Douas';

  @override
  String get scopeHadith => 'Hadiths';

  @override
  String get librarySituations => 'Toutes les situations';

  @override
  String get libraryForNow => 'Maintenant';

  @override
  String duaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count douas', one: '1 doua');
    return '$_temp0';
  }

  @override
  String get libraryPreparing => 'Préparation de la recherche de hadiths. Une seule fois.';

  @override
  String get libraryRefine => 'Les 60 premiers. Ajoutez un mot pour affiner.';

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
  String get copyText => 'Copier';

  @override
  String get copied => 'Copié';

  @override
  String get openSource => 'Ouvrir la source';

  @override
  String get readingTitle => 'Taille de lecture';

  @override
  String get readingHint => 'Arabe, translittération et sens, chacun à part';

  @override
  String get readingArabic => 'Arabe';

  @override
  String get readingTransliteration => 'Translittération';

  @override
  String get readingMeaning => 'Sens';

  @override
  String stripLeft(String time, String prayer) {
    return '$time avant $prayer';
  }

  @override
  String get dayGuideToday => 'Sunna du jour';

  @override
  String fastToday(String day) {
    return 'Jeûne sunna aujourd\'hui · $day';
  }

  @override
  String fastTomorrow(String day) {
    return 'Jeûnez demain · $day';
  }

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get calendarLegendGuide => 'Avec un guide';

  @override
  String get calendarLegendFast => 'Jeûne sunna';

  @override
  String get calendarNote =>
      'Dates selon Umm al-Qura avec votre ajustement hégirien. Le 29 de Chaabane, Ramadan et Dhou al-Qi\'da, l\'accueil demande si le croissant a été vu.';

  @override
  String sightingTitle(String month) {
    return 'Le croissant de $month a-t-il été vu chez vous ?';
  }

  @override
  String get sightingBody =>
      'Votre réponse décale le calendrier pour que Ramadan, l\'Aïd et Arafat tombent les jours de votre communauté.';

  @override
  String sightingSeen(String month) {
    return 'Vu : $month commence';
  }

  @override
  String get sightingNotSeen => 'Pas vu : 30 jours';

  @override
  String get sightingUnsure => 'Pas sûr';

  @override
  String get ramadanSuhoor => 'Fin du suhour';

  @override
  String get ramadanIftar => 'Iftar';

  @override
  String ramadanIn(String time) {
    return 'dans $time';
  }

  @override
  String get ramadanDone => 'terminé';

  @override
  String announceTitle(String month) {
    return 'Ce soir se décide $month';
  }

  @override
  String announceBegins(String month, String authority) {
    return 'Selon $authority, $month commence demain.';
  }

  @override
  String announceThirty(String month, String authority) {
    return 'Selon $authority, $month complète 30 jours : demain est le 30.';
  }

  @override
  String get announceOffline => 'Hors ligne : dernières dates téléchargées. Waqt vérifiera à la reconnexion.';

  @override
  String announceChecking(String time) {
    return 'Waqt vérifie l\'annonce toutes les 30 minutes ce soir. Dernière vérification $time.';
  }

  @override
  String get authoritySaudi => 'Haut Conseil judiciaire saoudien';

  @override
  String get authorityDiyanet => 'Diyanet (Turquie)';

  @override
  String get authorityLocal => 'Observation locale du croissant';

  @override
  String get authoritySaudiHint => 'Observations annoncées, mises à jour en ligne';

  @override
  String get authorityDiyanetHint => 'Calendrier officiel turc, mis à jour en ligne';

  @override
  String get authorityLocalHint => 'Umm al-Qura ; le 29, vous dites si le croissant a été vu';

  @override
  String calendarSourceLine(String authority, String time) {
    return '$authority · vérifié $time';
  }

  @override
  String get calendarSourceLocal =>
      'Umm al-Qura avec votre ajustement. Le 29 de Chaabane, Ramadan et Dhou al-Qi\'da, l\'accueil demande si le croissant a été vu.';

  @override
  String announceUnknown(String month) {
    return 'L\'annonce n\'est pas encore parvenue à Waqt. Si le croissant est vu ce soir, $month commence demain ; sinon, ce mois compte 30 jours.';
  }

  @override
  String get adjustTitle => 'Ajuster les horaires';

  @override
  String get adjustRowHint => 'Aligner sur l\'horaire local ou la mosquée';

  @override
  String get adjustNone => 'Aucun';

  @override
  String adjustSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count horaires', one: '1 horaire');
    return '$_temp0';
  }

  @override
  String get adjustHint =>
      'Les horaires sont calculés pour votre position exacte. Si l\'horaire local (fédération, mosquée) diffère d\'une ou deux minutes, alignez-le ici.';

  @override
  String get adjustNote =>
      'Le suhour finit à Fajr et l\'iftar est à Maghrib : les ajuster déplace aussi suhour et iftar. Rappels et widget suivent.';

  @override
  String get adjustEarlier => '1 minute plus tôt';

  @override
  String get adjustLater => '1 minute plus tard';

  @override
  String get momentTaraweeh => 'Tarawih';

  @override
  String get showLess => 'Moins';

  @override
  String showAll(int count) {
    return 'Tout afficher ($count)';
  }

  @override
  String get hadithUnavailable =>
      'La recherche de hadiths n\'est pas disponible ici. Elle fonctionne dans l\'application Android.';

  @override
  String get hadithLibraryTitle => 'Bibliothèque de hadiths';

  @override
  String get hadithLibraryBody =>
      'L\'encyclopédie HadeethEnc dans votre langue : hadiths authentiques avec l\'arabe, le degré et l\'explication, consultables hors ligne. Téléchargée une fois.';

  @override
  String hadithLibraryDownload(String mb) {
    return 'Télécharger ($mb Mo)';
  }

  @override
  String hadithLibraryProgress(int percent) {
    return 'Téléchargement… $percent %';
  }

  @override
  String get hadithLibraryFailed => 'Le téléchargement n\'a pas abouti. Vérifiez votre connexion.';

  @override
  String get hadithLibraryRetry => 'Réessayer';

  @override
  String get hadithLibraryNote =>
      'Issu de HadeethEnc.com, sans modification. L\'accueil, les listes et le compteur fonctionnent sans elle.';

  @override
  String counterToday(String count) {
    return 'Aujourd\'hui $count';
  }

  @override
  String get counterTodayTitle => 'Dit aujourd\'hui';

  @override
  String get counterTodayAll => 'Tous les dhikr';

  @override
  String get counterResetRound => 'Recommencer ce tour';

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
  String get counterAddOwn => 'Ajouter le vôtre';

  @override
  String get counterOwnName => 'Ce que vous direz';

  @override
  String get counterOwnArabic => 'Arabe (facultatif)';

  @override
  String get counterOwnTarget => 'Combien de fois';

  @override
  String get counterSave => 'Enregistrer';

  @override
  String get counterRemove => 'Retirer';

  @override
  String get counterSectionReward => 'Avec une récompense promise';

  @override
  String get counterSectionYours => 'Les vôtres';

  @override
  String get sheetExplanation => 'Explication';

  @override
  String get sheetEnglishOriginal => 'Anglais (sunnah.com)';

  @override
  String sourceHadeethEnc(String date) {
    return 'Traduction et explication : HadeethEnc.com, sans modification (récupéré le $date).';
  }

  @override
  String get openHadeethEnc => 'HadeethEnc';

  @override
  String heNotTranslated(String language) {
    return 'HadeethEnc n\'a pas encore traduit ce hadith en $language ; le texte arabe est affiché.';
  }

  @override
  String get libraryAllTopics => 'Tous les thèmes';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String qiblaFrom(String city) {
    return 'Depuis $city';
  }

  @override
  String get qiblaFacing => 'Vous faites face à la qibla';

  @override
  String get qiblaTurnRight => 'Tournez à droite';

  @override
  String get qiblaTurnLeft => 'Tournez à gauche';

  @override
  String get qiblaDirection => 'Direction';

  @override
  String qiblaBearing(String deg) {
    return '$deg° depuis le nord';
  }

  @override
  String get qiblaDistance => 'Distance jusqu\'à la Kaaba';

  @override
  String qiblaKm(String km) {
    return '$km km';
  }

  @override
  String get qiblaHoldFlat => 'Tenez le téléphone à plat';

  @override
  String get qiblaCalibrate => 'Si la direction dérive, décrivez un 8 avec le téléphone, loin du métal et des aimants.';

  @override
  String qiblaNoCompass(String deg) {
    return 'Cet appareil n\'a pas de boussole. Orientez-vous à $deg° du nord à l\'aide d\'un repère ou du soleil.';
  }

  @override
  String get qiblaNoPlace => 'Choisissez une ville pour trouver la qibla.';

  @override
  String get qiblaNorthShort => 'N';

  @override
  String get footerHandcrafted => 'CONÇU AVEC SOIN PAR';

  @override
  String get footerSignatureLabel => 'Signature d\'Ornob Aadi';

  @override
  String footerVersion(String version) {
    return 'WAQT · BÊTA $version';
  }

  @override
  String get footerTagline => 'HORS LIGNE · SANS PUB · SANS PISTAGE';

  @override
  String get footerDuaRequest => 'Pensez à moi dans vos invocations.';

  @override
  String remTitle(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'ramadan': '🌙 Le Ramadan commence ce soir',
      'dhulHijjah': '🕋 Les dix meilleurs jours commencent',
      'arafah': '🤲 Demain, c\'est le jour d\'Arafat',
      'eidFitr': '🎉 Demain, c\'est l\'Aïd al-Fitr',
      'eidAdha': '🐑 Demain, c\'est l\'Aïd al-Adha',
      'tasua': '🗓️ Jeûne de Tasu\'a demain',
      'ashura': '🌊 Demain, c\'est Achoura',
      'whiteDays': '🌕 Les jours blancs commencent demain',
      'monday': '🗓️ Jeûne du lundi demain',
      'thursday': '🗓️ Jeûne du jeudi demain',
      'jumuah': '🕌 Joumou\'a moubarak',
      'fridayLastHour': '🤲 L\'heure du vendredi',
      'suhoor': '🌙 C\'est l\'heure du souhour',
      'iftar': '🌅 C\'est l\'heure de rompre le jeûne',
      'laylatAlQadr': '✨ Cette nuit est peut-être Laylat al-Qadr',
      'morningAdhkar': '☀️ Invocations du matin',
      'eveningAdhkar': '🌇 Invocations du soir',
      'lastThird': '🌌 Le dernier tiers de la nuit',
      'bedtime': '😴 Avant de dormir',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remBody(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'ramadan': 'Tarawih ce soir, souhour avant l\'aube. Qui jeûne le Ramadan avec foi et espoir de récompense voit ses péchés passés pardonnés (Boukhari).',
      'dhulHijjah': 'Il n\'est pas de jours où les bonnes œuvres sont plus aimées d\'Allah que ces dix-là (Boukhari). Takbir, jeûne, aumône.',
      'arafah': 'Son jeûne efface les péchés de l\'année passée et de l\'année à venir (Mouslim). Formule ton intention ce soir.',
      'eidFitr': 'Donne la zakat al-fitr avant la prière de l\'Aïd, et dis le takbir dès ce soir.',
      'eidAdha': 'Dis le takbir, prie l\'Aïd au matin, puis offre ton sacrifice.',
      'tasua': 'Le Prophète ﷺ comptait jeûner le 9 avec Achoura (Mouslim). Achoura vient le lendemain.',
      'ashura': 'Le jeûne d\'Achoura efface les péchés de l\'année passée (Mouslim). Formule ton intention ce soir.',
      'whiteDays': 'Jeûne les 13, 14 et 15 : trois jours par mois valent le jeûne de toute l\'année (Boukhari).',
      'monday': 'Les œuvres sont présentées le lundi et le jeudi, et le Prophète ﷺ aimait qu\'elles le soient pendant qu\'il jeûnait (Tirmidhi).',
      'thursday': 'Les œuvres sont présentées le lundi et le jeudi, et le Prophète ﷺ aimait qu\'elles le soient pendant qu\'il jeûnait (Tirmidhi).',
      'jumuah': 'Fais le ghousl, pars tôt, lis la sourate al-Kahf et prie beaucoup sur le Prophète ﷺ aujourd\'hui.',
      'fridayLastHour': 'Il y a le vendredi une heure où toute invocation est exaucée (Boukhari). Cherche-la maintenant, avant le Maghrib.',
      'suhoor': 'Prenez le souhour, car il y a en lui une bénédiction (Boukhari). L\'aube approche.',
      'iftar': 'Les gens restent dans le bien tant qu\'ils se hâtent de rompre le jeûne (Boukhari). Invoque Allah en le rompant.',
      'laylatAlQadr': 'Meilleure que mille mois (Coran 97:3). Prie, et dis : Allahumma innaka ʿafuwwun tuhibbul-ʿafwa faʿfu ʿanni (Tirmidhi).',
      'morningAdhkar': 'Quelques minutes de rappel pour commencer la journée sous la protection d\'Allah.',
      'eveningAdhkar': 'Le rappel du soir, avant le Maghrib. Touche pour le lire.',
      'lastThird':
          'Notre Seigneur descend au ciel le plus proche et dit : qui M\'invoque, que Je l\'exauce ? (Boukhari)',
      'bedtime': 'Ayat al-Koursi, les deux derniers versets d\'al-Baqara et l\'invocation du sommeil. Deux minutes.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'ramadan': 'Début du Ramadan',
      'dhulHijjah': 'Dhoul Hijja et Arafat',
      'eid': 'Aïd',
      'ashura': 'Tasu\'a et Achoura',
      'whiteDays': 'Les jours blancs',
      'monThu': 'Jeûnes du lundi et du jeudi',
      'jumuah': 'Matin du vendredi',
      'fridayLastHour': 'L\'heure du vendredi',
      'suhoor': 'Souhour',
      'iftar': 'Iftar',
      'laylatAlQadr': 'Nuits impaires des dix dernières',
      'morningAdhkar': 'Invocations du matin',
      'eveningAdhkar': 'Invocations du soir',
      'lastThird': 'Le dernier tiers de la nuit',
      'bedtime': 'Avant de dormir',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remWhen(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'ramadan': 'Le soir où commence le Ramadan',
      'dhulHijjah': 'Au début des dix jours, et la veille d\'Arafat',
      'eid': 'La veille au soir de chaque Aïd',
      'ashura': 'Les veilles du 9 et du 10 mouharram',
      'whiteDays': 'La veille du 13, chaque mois',
      'monThu': 'Les dimanches et mercredis soir',
      'jumuah': 'Le vendredi matin',
      'fridayLastHour': 'Le vendredi, la dernière heure avant le Maghrib',
      'suhoor': 'Avant l\'aube, chaque jour du Ramadan',
      'iftar': 'Au Maghrib, chaque jour du Ramadan',
      'laylatAlQadr': 'Nuits du 21, 23, 25, 27 et 29',
      'morningAdhkar': 'Après le Fajr',
      'eveningAdhkar': 'Après l\'Asr',
      'lastThird': 'Quand commence le dernier tiers',
      'bedtime': 'À ton heure de coucher',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get remHeroTitle => 'Ne manque pas les moments qui comptent';

  @override
  String get remHeroBody =>
      'Waqt te rappelle seulement les moments les plus récompensés : Arafat, Achoura, Laylat al-Qadr, chaque vendredi. Chaque rappel dit quoi faire et pourquoi, avec sa source.';

  @override
  String get remTurnOn => 'Activer les rappels';

  @override
  String get remComingUp => 'Prochains rappels';

  @override
  String get remNothingSoon => 'Rien dans le mois qui vient. Active d\'autres rappels ci-dessous.';

  @override
  String get remPreview => 'Aperçu';

  @override
  String get remTest => 'M\'envoyer un rappel d\'essai';

  @override
  String get remTestSent => 'Envoyé. Regarde tes notifications.';

  @override
  String get remNow => 'maintenant';

  @override
  String get remGroupSpecial => 'Jours bénis';

  @override
  String get remGroupFriday => 'Chaque vendredi';

  @override
  String get remGroupRamadan => 'Pendant le Ramadan';

  @override
  String get remGroupDaily => 'Chaque jour';

  @override
  String get remDailyNote => 'Désactivés par défaut, pour que les rappels les plus importants ressortent.';

  @override
  String get qiblaFromLabel => 'Qibla depuis';

  @override
  String get qiblaToLeft => 'sur ta gauche';

  @override
  String get qiblaToRight => 'sur ta droite';

  @override
  String qiblaToMakkah(String km) {
    return '$km km de La Mecque';
  }

  @override
  String get qiblaHint => 'Tourne jusqu\'à ce que la flèche pointe vers le haut et que l\'écran s\'illumine.';

  @override
  String get deedOnTime => 'À l’heure';

  @override
  String get deedJamaah => 'En assemblée';

  @override
  String get deedQada => 'Rattrapée plus tard';

  @override
  String get deedNotPrayed => 'Non cochée';

  @override
  String deedPrayedCount(String done) {
    return '$done sur 5 prières';
  }

  @override
  String get deedRingHint => 'Cochez une prière sur Maintenant une fois accomplie. Vous seul le voyez.';

  @override
  String deedStreak(String days) {
    return '$days jours de suite avec les cinq';
  }

  @override
  String get progressTitle => 'Vos progrès';

  @override
  String get progressThisWeek => 'Cette semaine';

  @override
  String get progressBestRun => 'Plus longue série des cinq';

  @override
  String get progressQada => 'Non cochées, à rattraper (30 j)';

  @override
  String progressDays(String days) {
    return '$days jours';
  }

  @override
  String get progressReflection =>
      '« Les œuvres les plus aimées d’Allah sont les plus régulières, même si elles sont peu nombreuses. » (Bukhari, Muslim)';

  @override
  String progressOfPrayers(String total) {
    return 'sur $total prières';
  }

  @override
  String get progressOnTimeShort => 'à l’heure';

  @override
  String get progressCurrentRun => 'jours de suite';

  @override
  String get progressByPrayer => 'Chaque prière, 30 derniers jours';

  @override
  String progressHardest(String prayer) {
    return '$prayer demande le plus d’attention en ce moment.';
  }

  @override
  String get progressWeeks => '12 dernières semaines';

  @override
  String get progressEmpty =>
      'Touchez une prière sur Maintenant une fois accomplie. Vos jours se remplissent ici, sur ce téléphone seulement.';

  @override
  String get progressEditHint => 'Touchez un jour pour noter vos prières.';

  @override
  String durShortHm(String h, String m) {
    return '${h}h$m';
  }

  @override
  String durShortM(String m) {
    return '$m min';
  }

  @override
  String beadLeft(String time) {
    return 'reste $time';
  }

  @override
  String beadIn(String time) {
    return 'dans $time';
  }

  @override
  String get beadEnded => 'terminé';

  @override
  String get onbWelcomeTitle => 'La bonne invocation pour chaque instant';

  @override
  String get onbWelcomeBody => 'Toutes tirées de la Sunna, avec leur source.';

  @override
  String get onbWelcomeNote => 'Gratuit. Sans compte, sans publicité.';

  @override
  String get onbBegin => 'Commencer';

  @override
  String get onbLanguageTitle => 'Choisissez votre langue';

  @override
  String get onbLanguageBody => 'Les invocations restent toujours en arabe.';

  @override
  String get onbPhoneLanguage => 'Langue du téléphone';

  @override
  String get onbContinue => 'Continuer';

  @override
  String get onbLocationTitle => 'D\'où priez-vous ?';

  @override
  String get onbLocationBody => 'Pour les heures de prière et la qibla. Elle reste sur ce téléphone.';

  @override
  String get onbCityInstead => 'Choisir une ville';

  @override
  String get onbRemindersTitle => 'Seulement les moments qui comptent';

  @override
  String get onbRemindersBody => 'Arafat, Achoura, l\'Aïd et le vendredi. Jamais de bruit.';

  @override
  String get onbRemindersOn => 'Activer les rappels';

  @override
  String get onbLater => 'Plus tard';

  @override
  String onbStep(int n, int total) {
    return 'Étape $n sur $total';
  }

  @override
  String get beadOnTime => 'à l\'heure';

  @override
  String get beadJamaah => 'en groupe';

  @override
  String get beadLate => 'rattrapée';

  @override
  String get comingUpTitle => 'À venir';

  @override
  String comingIn(String time) {
    return 'dans $time';
  }

  @override
  String get beadTapToMark => 'cocher';

  @override
  String get duasTabSay => 'Invocations à dire';

  @override
  String get duasTabHadith => 'Hadiths';

  @override
  String get duasRightNow => 'En ce moment';

  @override
  String get duasByTask => 'Selon ce que vous faites';

  @override
  String duasCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count invocations', one: '1 invocation');
    return '$_temp0';
  }

  @override
  String get duasTaskIntro => 'Les paroles à dire, dans l\'ordre. Ouvrez-en une pour son sens et sa source.';

  @override
  String get duasGoThrough => 'Les lire une à une';

  @override
  String duaSayTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'À dire $count fois',
      one: 'À dire une fois',
    );
    return '$_temp0';
  }

  @override
  String get duaHowToSay => 'Prononciation';

  @override
  String get duaMeaning => 'Sens';

  @override
  String get duaReference => 'Source';

  @override
  String get duaSeeHadith => 'Voir le hadith en entier';

  @override
  String duaNoMeaning(String language) {
    return 'HadeethEnc n\'a pas encore publié le sens de ces paroles seules en $language. Le hadith complet montre ce qui existe.';
  }

  @override
  String duaPosition(int index, int total) {
    return '$index sur $total';
  }

  @override
  String get duaNext => 'Suivante';

  @override
  String get duaPrevious => 'Précédente';

  @override
  String get duaDone => 'Terminé';
}
