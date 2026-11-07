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
  String get settingsDeveloperHint =>
      'Fake clock, day jumps and the reference checker';

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
  String get gpsServiceOff =>
      'La localisation est désactivée sur ce téléphone. Activez-la ou choisissez une ville.';

  @override
  String get gpsDenied =>
      'L\'autorisation de localisation a été refusée. Vous pouvez choisir une ville.';

  @override
  String get gpsDeniedForever =>
      'L\'autorisation de localisation est bloquée. Autorisez-la dans les réglages ou choisissez une ville.';

  @override
  String get gpsTimeout =>
      'Position introuvable. Réessayez ou choisissez une ville.';

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
  String get asrStandardHint =>
      'Chafiite, malikite, hanbalite : ombre égale à l\'objet';

  @override
  String get asrHanafi => 'Hanafite';

  @override
  String get asrHanafiHint => 'Ombre égale au double de l\'objet';

  @override
  String get settingsHighLat => 'Règle des hautes latitudes';

  @override
  String get highLatAuto => 'Automatique';

  @override
  String get highLatAutoHint =>
      'Septième de la nuit au-delà de 48°, milieu de la nuit en deçà';

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
  String get hijriAdjustHint =>
      'Pour suivre l\'observation du croissant chez vous';

  @override
  String get hijriOffsetNone => 'Aucun';

  @override
  String hijriOffsetDays(String value) {
    return '$value j';
  }

  @override
  String get settingsAttribution =>
      'Données des villes © GeoNames, CC BY 4.0. Horaires calculés sur l\'appareil.';

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
  String get draftNotice =>
      'Brouillon non vérifié, visible uniquement en version de développement';

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
  String get sheetTextPending =>
      'Le texte apparaîtra ici une fois cette référence vérifiée sur sa source.';

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
  String get notifHint => 'Horaires de prière et moments, selon vos choix';

  @override
  String get notifPermission => 'Notifications';

  @override
  String get notifAllowed => 'Autorisé';

  @override
  String get notifAllow => 'Autoriser';

  @override
  String get notifExact => 'Ponctualité';

  @override
  String get notifExactHint =>
      'Pour que les rappels de prière arrivent à la minute près';

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
  String get setupCardTitle => 'Rappels discrets';

  @override
  String get setupCardBody =>
      'Un léger rappel à chaque prière. Vous choisissez lesquels, et rien ne quitte votre téléphone.';

  @override
  String get setupCardAction => 'Configurer';

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
  String get counterOpen => 'Ouvrir le compteur';

  @override
  String get reportContent => 'Signaler un problème dans ce texte';

  @override
  String get reportProblem => 'Signaler un problème';

  @override
  String get reportProblemHint =>
      'Ouvre un brouillon d\'e-mail. Vous voyez tout avant l\'envoi.';

  @override
  String get privacyTitle => 'Confidentialité';

  @override
  String get privacyBody =>
      'Tout est calculé sur ce téléphone. Waqt n\'a ni compte, ni publicité, ni statistiques.';

  @override
  String placeTime(String city) {
    return 'Heure de $city';
  }

  @override
  String get testModeUnlocked =>
      'Test mode is on. Find it at the bottom of Settings.';

  @override
  String get debugJumpDay => 'Jump to a day';

  @override
  String get debugNextFriday => 'Next Friday';

  @override
  String get debugContent => 'Content';

  @override
  String get debugShowUnchecked => 'Show unchecked content';

  @override
  String get debugShowUncheckedHint =>
      'On this phone only. Unchecked items are marked as drafts.';

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
  String get checkerWrongHint =>
      'What is wrong, and the correct reference if you know it';

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
  String get counterFreeHint =>
      'Comptez ce que vous voulez, avec votre objectif';

  @override
  String get counterAfterSalah => 'Après la prière : 33 · 33 · 34';

  @override
  String get counterHaptics => 'Vibrer à chaque compte';

  @override
  String get counterAfterSalahName => 'Après la prière';

  @override
  String get librarySearchAll => 'Chercher douas et hadiths';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count douas',
      one: '1 doua',
    );
    return '$_temp0';
  }

  @override
  String get libraryPreparing =>
      'Préparation de la recherche de hadiths. Une seule fois.';

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
  String get announceOffline =>
      'Hors ligne : dernières dates téléchargées. Waqt vérifiera à la reconnexion.';

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
  String get authoritySaudiHint =>
      'Observations annoncées, mises à jour en ligne';

  @override
  String get authorityDiyanetHint =>
      'Calendrier officiel turc, mis à jour en ligne';

  @override
  String get authorityLocalHint =>
      'Umm al-Qura ; le 29, vous dites si le croissant a été vu';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horaires',
      one: '1 horaire',
    );
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
}
