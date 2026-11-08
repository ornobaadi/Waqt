// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Waqt';

  @override
  String get navNow => 'Şimdi';

  @override
  String get navToday => 'Bugün';

  @override
  String get navDuas => 'Dualar';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get prayerFajr => 'İmsak';

  @override
  String get prayerSunrise => 'Güneş';

  @override
  String get prayerDhuhr => 'Öğle';

  @override
  String get prayerAsr => 'İkindi';

  @override
  String get prayerMaghrib => 'Akşam';

  @override
  String get prayerIsha => 'Yatsı';

  @override
  String get momentNight => 'Gece';

  @override
  String get momentBedtime => 'Uyku vakti';

  @override
  String get timePending => '–';

  @override
  String get nowLocationTitle => 'Nerede namaz kılıyorsunuz?';

  @override
  String get nowLocationBody =>
      'Namaz vakitleri konumunuza göre telefonunuzda hesaplanır. Hiçbir veri cihazdan çıkmaz.';

  @override
  String get todayEmptyTitle => 'Gününüz, an an';

  @override
  String get todayEmptyBody =>
      'Sabahtan gecenin son üçte birine kadar bugünün her vakti, namaz vakitleri hesaplanınca burada sıralanır.';

  @override
  String get duasEmptyTitle => 'Yalnızca doğrulanmış kaynaklar';

  @override
  String get duasEmptyBody =>
      'Kütüphane, her metin asıl kaynağıyla karşılaştırılıp bir âlim tarafından onaylandığında açılacak.';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageSystem => 'Cihaz dili';

  @override
  String get settingsDeveloper => 'Test mode';

  @override
  String get settingsDeveloperHint => 'Fake clock, day jumps and the reference checker';

  @override
  String get settingsAbout => 'Waqt hakkında';

  @override
  String settingsVersion(String version) {
    return 'Sürüm $version';
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
  String get waqtMorning => 'Kuşluk';

  @override
  String nextIn(String prayer, String time) {
    return '$prayer vaktine $time';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get hijriMonth1 => 'Muharrem';

  @override
  String get hijriMonth2 => 'Safer';

  @override
  String get hijriMonth3 => 'Rebiülevvel';

  @override
  String get hijriMonth4 => 'Rebiülahir';

  @override
  String get hijriMonth5 => 'Cemaziyelevvel';

  @override
  String get hijriMonth6 => 'Cemaziyelahir';

  @override
  String get hijriMonth7 => 'Recep';

  @override
  String get hijriMonth8 => 'Şaban';

  @override
  String get hijriMonth9 => 'Ramazan';

  @override
  String get hijriMonth10 => 'Şevval';

  @override
  String get hijriMonth11 => 'Zilkade';

  @override
  String get hijriMonth12 => 'Zilhicce';

  @override
  String get locationUseGps => 'Konumumu kullan';

  @override
  String get locationChooseCity => 'Şehir seç';

  @override
  String get locationLocating => 'Konum bulunuyor…';

  @override
  String get gpsServiceOff => 'Bu telefonda konum kapalı. Açın veya bir şehir seçin.';

  @override
  String get gpsDenied => 'Konum izni reddedildi. Bunun yerine bir şehir seçebilirsiniz.';

  @override
  String get gpsDeniedForever => 'Konum izni engellendi. Ayarlardan izin verin veya bir şehir seçin.';

  @override
  String get gpsTimeout => 'Konum alınamadı. Tekrar deneyin veya bir şehir seçin.';

  @override
  String get openSettings => 'Ayarları aç';

  @override
  String get settingsLocation => 'Konum';

  @override
  String get settingsNotSet => 'Ayarlanmadı';

  @override
  String get settingsUseGps => 'Şu anki konumu kullan';

  @override
  String get settingsGpsSource => 'GPS ile';

  @override
  String get settingsPrayerTimes => 'Namaz vakitleri';

  @override
  String get settingsMethod => 'Hesaplama yöntemi';

  @override
  String get settingsRegionalDefault => 'Bölgeniz için varsayılan';

  @override
  String get settingsAsr => 'İkindi vakti';

  @override
  String get asrStandard => 'Cumhur';

  @override
  String get asrStandardHint => 'Şâfiî, Mâlikî, Hanbelî: gölge cismin boyu kadar';

  @override
  String get asrHanafi => 'Hanefî';

  @override
  String get asrHanafiHint => 'Gölge cismin iki katı';

  @override
  String get settingsHighLat => 'Yüksek enlem kuralı';

  @override
  String get highLatAuto => 'Otomatik';

  @override
  String get highLatAutoHint => '48° üstünde gecenin yedide biri, altında gece yarısı';

  @override
  String get highLatMiddle => 'Gece yarısı';

  @override
  String get highLatSeventh => 'Gecenin yedide biri';

  @override
  String get highLatTwilight => 'Şafak açısı';

  @override
  String get settingsCalendar => 'Takvim';

  @override
  String get settingsHijriAdjust => 'Hicrî tarih düzeltmesi';

  @override
  String get hijriAdjustHint => 'Bulunduğunuz yerdeki hilal gözlemine uyması için';

  @override
  String get hijriOffsetNone => 'Yok';

  @override
  String hijriOffsetDays(String value) {
    return '$value gün';
  }

  @override
  String get settingsAttribution => 'Şehir verileri © GeoNames, CC BY 4.0. Namaz vakitleri cihazda hesaplanır.';

  @override
  String get citySearchHint => 'Şehir ara';

  @override
  String cityNoResults(String query) {
    return '“$query” ile eşleşen şehir yok';
  }

  @override
  String get methodMwl => 'Dünya İslam Birliği';

  @override
  String get methodIsna => 'ISNA, Kuzey Amerika';

  @override
  String get methodEgypt => 'Mısır Genel Ölçüm Kurumu';

  @override
  String get methodKarachi => 'İslami İlimler Üniversitesi, Karaçi';

  @override
  String get methodUmmAlQura => 'Ümmü\'l-Kurâ, Mekke';

  @override
  String get methodDubai => 'Dubai';

  @override
  String get methodQatar => 'Katar';

  @override
  String get methodKuwait => 'Kuveyt';

  @override
  String get methodSingapore => 'Singapur, Malezya, Endonezya';

  @override
  String get methodTurkey => 'Diyanet İşleri Başkanlığı';

  @override
  String get methodTehran => 'Jeofizik Enstitüsü, Tahran';

  @override
  String get methodMoonsighting => 'Moonsighting Committee';

  @override
  String get timesEstimated =>
      'Tahminî. Güneş bugün burada normal doğup batmıyor; vakitler 65° enleme göre hesaplandı.';

  @override
  String get momentLastThird => 'Gecenin son üçte biri';

  @override
  String get momentFridayLastHour => 'Cumanın son saati';

  @override
  String momentAdhanIqamah(String prayer) {
    return '$prayer kametinden önce';
  }

  @override
  String momentAfterSalah(String prayer) {
    return '$prayer namazından sonra';
  }

  @override
  String get momentRestrictedSunrise => 'Güneş doğarken';

  @override
  String get momentRestrictedZawal => 'Güneş tepedeyken';

  @override
  String get momentRestrictedSunset => 'Güneş batarken';

  @override
  String get momentDuha => 'Kuşluk';

  @override
  String get momentMorningAdhkar => 'Sabah zikirleri';

  @override
  String get momentEveningAdhkar => 'Akşam zikirleri';

  @override
  String get kindRestricted => 'Nafile namaz için kerahat vakti';

  @override
  String get rightNow => 'Şu an';

  @override
  String until(String time) {
    return '$time saatine kadar';
  }

  @override
  String get comingUp => 'Sıradakiler';

  @override
  String startsAt(String time) {
    return '$time';
  }

  @override
  String startsIn(String time) {
    return '$time sonra';
  }

  @override
  String get timelineNow => 'Şimdi';

  @override
  String get debugJump => 'Jump to moment';

  @override
  String get statusDraft => 'Taslak';

  @override
  String get statusChecked => 'Kontrol edildi';

  @override
  String get draftNotice => 'Kontrol edilmemiş taslak, yalnızca geliştirme sürümünde görünür';

  @override
  String get collectionQuran => 'Kur\'an';

  @override
  String get collectionBukhari => 'Buhârî';

  @override
  String get collectionMuslim => 'Müslim';

  @override
  String get collectionAbudawud => 'Ebû Dâvûd';

  @override
  String get collectionTirmidhi => 'Tirmizî';

  @override
  String get collectionNasai => 'Nesâî';

  @override
  String get collectionIbnmajah => 'İbn Mâce';

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
  String get sheetSource => 'Kaynak';

  @override
  String get sheetNarrator => 'Rivayet eden';

  @override
  String get sheetGrade => 'Derece';

  @override
  String get sheetGradedBy => 'Hükmeden';

  @override
  String get sheetTranslation => 'Meal';

  @override
  String get sheetReview => 'İnceleme';

  @override
  String sheetOpen(String host) {
    return '$host üzerinde aç';
  }

  @override
  String get sheetTextPending => 'Bu kaynak asıl metinle karşılaştırıldığında metin burada görünecek.';

  @override
  String get statusApproved => 'Âlim onaylı';

  @override
  String get gradeSahih => 'Sahih';

  @override
  String get gradeHasan => 'Hasen';

  @override
  String reviewCheckedBy(String name) {
    return 'Kontrol eden: $name';
  }

  @override
  String reviewApprovedBy(String name) {
    return 'Onaylayan: $name';
  }

  @override
  String checklistProgress(String done, String total) {
    return '$done / $total';
  }

  @override
  String get checklistTitleBedtime => 'Uyumadan önce';

  @override
  String get checklistTitleJumuah => 'Cuma';

  @override
  String get momentJumuah => 'Cuma';

  @override
  String get librarySearch => 'Dua ve kaynak ara';

  @override
  String libraryNoMatch(String query) {
    return '“$query” için sonuç yok';
  }

  @override
  String libraryCount(String count) {
    return '$count öğe';
  }

  @override
  String get libraryOther => 'Diğer';

  @override
  String get momentLastThirdShort => 'Son üçte bir';

  @override
  String reminderBody(String time, String place) {
    return '$time · $place';
  }

  @override
  String get widgetEmptyBody => 'Konumunuzu ayarlamak için Waqt\'ı açın';

  @override
  String get notifTitle => 'Hatırlatmalar';

  @override
  String get notifHint => 'Arefe, Âşûrâ, cuma, Ramazan ve dahası';

  @override
  String get notifPermission => 'Bildirimler';

  @override
  String get notifAllowed => 'İzin verildi';

  @override
  String get notifAllow => 'İzin ver';

  @override
  String get notifExact => 'Tam zamanında';

  @override
  String get notifExactHint => 'Namaz hatırlatmalarının dakikasında gelmesi için';

  @override
  String get notifBattery => 'Pil optimizasyonu';

  @override
  String get notifBatteryOk => 'Kısıtlamasız';

  @override
  String get notifBatteryFix => 'Ayarları aç';

  @override
  String get notifBatteryHint => 'Bazı telefonlar arka planda hatırlatmaları durdurur. Waqt\'ı Kısıtlamasız yapın.';

  @override
  String notifBatteryHintOem(String maker) {
    return '$maker telefonlar arka planda hatırlatmaları sık sık durdurur. Waqt\'ı Kısıtlamasız yapın.';
  }

  @override
  String get notifPrayers => 'Namaz vakitleri';

  @override
  String get notifMoments => 'Anlar';

  @override
  String get notifSound => 'Ses çal';

  @override
  String get notifSoundHint => 'Kapalıyken tüm hatırlatmalar sessiz olur';

  @override
  String notifScheduled(String count, String date) {
    return '$date tarihine kadar $count hatırlatma planlandı';
  }

  @override
  String get notifNone => 'Planlanmış hatırlatma yok';

  @override
  String get notifStatus => 'Durum';

  @override
  String get setupCardTitle => 'Waqt sana hatırlatsın';

  @override
  String get setupCardBody => 'Arefe, Âşûrâ veya bayramdan önceki gece ve her cuma: ne yapacağın ve nedeni.';

  @override
  String get setupCardAction => 'Aç';

  @override
  String get setupCardDismiss => 'Şimdi değil';

  @override
  String get momentLaylatAlQadr => 'Son on gecenin tek gecelerinden biri';

  @override
  String get momentSuhoor => 'Sahur';

  @override
  String get momentIftar => 'İftar';

  @override
  String get occEidAlFitr => 'Ramazan Bayramı';

  @override
  String get occEidAlAdha => 'Kurban Bayramı';

  @override
  String get occArafah => 'Arefe günü';

  @override
  String get occTashreeq => 'Teşrik günleri';

  @override
  String get occAshura => 'Aşure';

  @override
  String get occTasua => 'Tâsûâ';

  @override
  String get occLastTen => 'Son on gece';

  @override
  String occRamadan(String day) {
    return 'Ramazan $day';
  }

  @override
  String get occFirstTen => 'Zilhiccenin ilk on günü';

  @override
  String get occBid => 'Eyyâm-ı Bîz';

  @override
  String get occMonday => 'Pazartesi orucu';

  @override
  String get occThursday => 'Perşembe orucu';

  @override
  String get counterTitle => 'Sayaç';

  @override
  String get counterTap => 'Saymak için herhangi bir yere dokunun';

  @override
  String get counterReset => 'Sıfırla';

  @override
  String counterRound(String n) {
    return '$n. tur';
  }

  @override
  String get counterTarget => 'Tur başına tane';

  @override
  String get counterOpen => 'Tesbih sayacı';

  @override
  String get reportContent => 'Bu metindeki bir hatayı bildir';

  @override
  String get reportProblem => 'Sorun bildir';

  @override
  String get reportProblemHint => 'Bir e-posta taslağı açar. Göndermeden önce her şeyi görürsünüz.';

  @override
  String get privacyTitle => 'Gizlilik';

  @override
  String get privacyBody => 'Her şey bu telefonda hesaplanır. Waqt\'ta hesap, reklam veya analiz yoktur.';

  @override
  String placeTime(String city) {
    return '$city saati';
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
    return '$time kaldı';
  }

  @override
  String windowPreferred(String time) {
    return 'en iyisi $time öncesi';
  }

  @override
  String durHm(String h, String m) {
    return '$h sa $m dk';
  }

  @override
  String durM(String m) {
    return '$m dk';
  }

  @override
  String get counterChoose => 'Zikri değiştir';

  @override
  String counterStep(String n, String total) {
    return 'Adım $n/$total';
  }

  @override
  String get counterFree => 'Serbest sayım';

  @override
  String get counterFreeHint => 'Kendi hedefinle her şeyi say';

  @override
  String get counterAfterSalah => 'Namazdan sonra: 33 · 33 · 34';

  @override
  String get counterHaptics => 'Her sayımda titreşim';

  @override
  String get counterAfterSalahName => 'Namazdan sonra';

  @override
  String get librarySearchAll => 'Hadis ve dua ara';

  @override
  String get scopeDuas => 'Dualar';

  @override
  String get scopeHadith => 'Hadisler';

  @override
  String get librarySituations => 'Her durum';

  @override
  String get libraryForNow => 'Şimdi';

  @override
  String duaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count dua', one: '1 dua');
    return '$_temp0';
  }

  @override
  String get libraryPreparing => 'Hadis araması hazırlanıyor. Bu yalnızca bir kez olur.';

  @override
  String get libraryRefine => 'İlk 60 gösteriliyor. Daraltmak için kelime ekleyin.';

  @override
  String get sourceHisn =>
      'Hisn al-Muslim by Sa\'id bin Ali bin Wahf al-Qahtani. Text, transliteration and translation as published on sunnah.com, via open-hadith-data.';

  @override
  String get sourceHadith =>
      'Arabic and English as published on sunnah.com, via open-hadith-data. Grades as given by the source.';

  @override
  String hisnNumber(String n) {
    return 'Hisnul Müslim $n';
  }

  @override
  String get copyText => 'Kopyala';

  @override
  String get copied => 'Kopyalandı';

  @override
  String get openSource => 'Kaynağı aç';

  @override
  String get readingTitle => 'Okuma boyutu';

  @override
  String get readingHint => 'Arapça, okunuş ve anlam, ayrı ayrı';

  @override
  String get readingArabic => 'Arapça';

  @override
  String get readingTransliteration => 'Okunuş';

  @override
  String get readingMeaning => 'Anlam';

  @override
  String stripLeft(String time, String prayer) {
    return '$prayer vaktine $time';
  }

  @override
  String get dayGuideToday => 'Bugünün sünneti';

  @override
  String fastToday(String day) {
    return 'Bugün sünnet oruç · $day';
  }

  @override
  String fastTomorrow(String day) {
    return 'Yarın oruç · $day';
  }

  @override
  String get calendarTitle => 'Takvim';

  @override
  String get calendarLegendGuide => 'Rehber var';

  @override
  String get calendarLegendFast => 'Sünnet oruç';

  @override
  String get calendarNote =>
      'Tarihler Ümmü\'l-Kurâ\'ya ve Hicri düzeltmenize göredir. Şaban, Ramazan ve Zilkade\'nin 29\'unda ana ekran hilalin görülüp görülmediğini sorar.';

  @override
  String sightingTitle(String month) {
    return '$month hilali bulunduğunuz yerde görüldü mü?';
  }

  @override
  String get sightingBody =>
      'Cevabınız takvimi kaydırır; Ramazan, bayram ve Arefe topluluğunuzun günlerine denk gelir.';

  @override
  String sightingSeen(String month) {
    return 'Görüldü: $month başlıyor';
  }

  @override
  String get sightingNotSeen => 'Görülmedi: 30 gün';

  @override
  String get sightingUnsure => 'Emin değilim';

  @override
  String get ramadanSuhoor => 'Sahur biter';

  @override
  String get ramadanIftar => 'İftar';

  @override
  String ramadanIn(String time) {
    return '$time sonra';
  }

  @override
  String get ramadanDone => 'tamam';

  @override
  String announceTitle(String month) {
    return 'Bu gece $month belli oluyor';
  }

  @override
  String announceBegins(String month, String authority) {
    return '$authority verisine göre $month yarın başlıyor.';
  }

  @override
  String announceThirty(String month, String authority) {
    return '$authority verisine göre $month 30 güne tamamlanıyor: yarın 30\'u.';
  }

  @override
  String get announceOffline => 'Çevrimdışı: son indirilen tarihler gösteriliyor. Bağlanınca yeniden kontrol edilecek.';

  @override
  String announceChecking(String time) {
    return 'Waqt bu gece her 30 dakikada duyuruyu kontrol ediyor. Son kontrol $time.';
  }

  @override
  String get authoritySaudi => 'Suudi Yüksek Yargı Konseyi';

  @override
  String get authorityDiyanet => 'Diyanet (Türkiye)';

  @override
  String get authorityLocal => 'Yerel hilal gözlemi';

  @override
  String get authoritySaudiHint => 'İlan edilen gözlemler, çevrimiçi güncellenir';

  @override
  String get authorityDiyanetHint => 'Türkiye\'nin resmî takvimi, çevrimiçi güncellenir';

  @override
  String get authorityLocalHint => 'Ümmü\'l-Kurâ; 29\'unda hilalin görülüp görülmediğini siz söylersiniz';

  @override
  String calendarSourceLine(String authority, String time) {
    return '$authority · $time kontrol edildi';
  }

  @override
  String get calendarSourceLocal =>
      'Ümmü\'l-Kurâ ve düzeltmeniz. Şaban, Ramazan ve Zilkade\'nin 29\'unda ana ekran hilali sorar.';

  @override
  String announceUnknown(String month) {
    return 'Duyuru henüz Waqt\'a ulaşmadı. Hilal bu gece görülürse $month yarın başlar; görülmezse bu ay 30 güne tamamlanır.';
  }

  @override
  String get adjustTitle => 'Vakitleri ayarla';

  @override
  String get adjustRowHint => 'Yerel takvime veya camiye uydur';

  @override
  String get adjustNone => 'Yok';

  @override
  String adjustSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count vakit', one: '1 vakit');
    return '$_temp0';
  }

  @override
  String get adjustHint =>
      'Vakitler tam konumunuza göre hesaplanır. Yerel takvim (ör. Diyanet ya da caminiz) bir iki dakika farklıysa burada eşitleyin.';

  @override
  String get adjustNote =>
      'Sahur imsakta biter, iftar akşamdadır; bunları ayarlamak sahur ve iftarı da kaydırır. Hatırlatmalar ve widget da uyar.';

  @override
  String get adjustEarlier => '1 dakika erken';

  @override
  String get adjustLater => '1 dakika geç';

  @override
  String get momentTaraweeh => 'Teravih';

  @override
  String get showLess => 'Daha az';

  @override
  String showAll(int count) {
    return 'Tümünü göster ($count)';
  }

  @override
  String get hadithUnavailable => 'Hadis araması burada yok. Android uygulamasında çalışır.';

  @override
  String get hadithLibraryTitle => 'Hadis kütüphanesi';

  @override
  String get hadithLibraryBody =>
      'HadeethEnc ansiklopedisi kendi dilinizde: Arapçası, derecesi ve açıklamasıyla sahih hadisler, çevrimdışı aranabilir. Bir kez indirilir.';

  @override
  String hadithLibraryDownload(String mb) {
    return 'İndir ($mb MB)';
  }

  @override
  String hadithLibraryProgress(int percent) {
    return 'İndiriliyor… %$percent';
  }

  @override
  String get hadithLibraryFailed => 'İndirme tamamlanmadı. Bağlantınızı kontrol edin.';

  @override
  String get hadithLibraryRetry => 'Tekrar dene';

  @override
  String get hadithLibraryNote =>
      'HadeethEnc.com\'dan, değiştirilmeden. Ana sayfa, listeler ve zikirmatik onsuz da çalışır.';

  @override
  String counterToday(String count) {
    return 'Bugün $count';
  }

  @override
  String get counterTodayTitle => 'Bugün söylenen';

  @override
  String get counterTodayAll => 'Tüm zikirler';

  @override
  String get counterResetRound => 'Bu turu baştan başlat';

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
  String get counterAddOwn => 'Kendi zikrini ekle';

  @override
  String get counterOwnName => 'Ne söyleyeceksin';

  @override
  String get counterOwnArabic => 'Arapça (isteğe bağlı)';

  @override
  String get counterOwnTarget => 'Kaç kez';

  @override
  String get counterSave => 'Kaydet';

  @override
  String get counterRemove => 'Kaldır';

  @override
  String get counterSectionReward => 'Fazileti bildirilen zikirler';

  @override
  String get counterSectionYours => 'Senin zikirlerin';

  @override
  String get sheetExplanation => 'Açıklama';

  @override
  String get sheetEnglishOriginal => 'İngilizce (sunnah.com)';

  @override
  String sourceHadeethEnc(String date) {
    return 'Çeviri ve açıklama: HadeethEnc.com, değiştirilmeden ($date tarihinde alındı).';
  }

  @override
  String get openHadeethEnc => 'HadeethEnc';

  @override
  String heNotTranslated(String language) {
    return 'HadeethEnc bu hadisi henüz $language diline çevirmedi; bu yüzden Arapçası gösteriliyor.';
  }

  @override
  String get libraryAllTopics => 'Tüm konular';

  @override
  String get qiblaTitle => 'Kıble';

  @override
  String qiblaFrom(String city) {
    return '$city konumundan';
  }

  @override
  String get qiblaFacing => 'Kıbleye dönüksünüz';

  @override
  String get qiblaTurnRight => 'Sağa dönün';

  @override
  String get qiblaTurnLeft => 'Sola dönün';

  @override
  String get qiblaDirection => 'Yön';

  @override
  String qiblaBearing(String deg) {
    return 'Kuzeyden $deg°';
  }

  @override
  String get qiblaDistance => 'Kâbe\'ye uzaklık';

  @override
  String qiblaKm(String km) {
    return '$km km';
  }

  @override
  String get qiblaHoldFlat => 'Telefonu düz tutun';

  @override
  String get qiblaCalibrate => 'Yön kayarsa telefonu metal ve mıknatıslardan uzakta 8 çizerek hareket ettirin.';

  @override
  String qiblaNoCompass(String deg) {
    return 'Bu cihazda pusula yok. Bir yer işaretine ya da güneşe bakarak kuzeyden $deg° yöne dönün.';
  }

  @override
  String get qiblaNoPlace => 'Kıbleyi bulmak için bir şehir seçin.';

  @override
  String get qiblaNorthShort => 'K';

  @override
  String get footerHandcrafted => 'ÖZENLE HAZIRLAYAN';

  @override
  String get footerSignatureLabel => 'Ornob Aadi\'nin imzası';

  @override
  String footerVersion(String version) {
    return 'WAQT · BETA $version';
  }

  @override
  String get footerTagline => 'ÇEVRİMDIŞI · REKLAMSIZ · TAKİPSİZ';

  @override
  String get footerDuaRequest => 'Dualarınızda beni de anın.';

  @override
  String remTitle(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'ramadan': '🌙 Ramazan bu gece başlıyor',
      'dhulHijjah': '🕋 En hayırlı on gün başladı',
      'arafah': '🤲 Yarın Arefe günü',
      'eidFitr': '🎉 Yarın Ramazan Bayramı',
      'eidAdha': '🐑 Yarın Kurban Bayramı',
      'tasua': '🗓️ Yarın Tâsûâ orucu',
      'ashura': '🌊 Yarın Âşûrâ günü',
      'whiteDays': '🌕 Eyyâm-ı bîd yarın başlıyor',
      'monday': '🗓️ Yarın pazartesi orucu',
      'thursday': '🗓️ Yarın perşembe orucu',
      'jumuah': '🕌 Hayırlı cumalar',
      'fridayLastHour': '🤲 Cumanın icabet saati',
      'suhoor': '🌙 Sahur vakti',
      'iftar': '🌅 İftar vakti',
      'laylatAlQadr': '✨ Bu gece Kadir Gecesi olabilir',
      'morningAdhkar': '☀️ Sabah zikirleri',
      'eveningAdhkar': '🌇 Akşam zikirleri',
      'lastThird': '🌌 Gecenin son üçte biri',
      'bedtime': '😴 Uyumadan önce',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remBody(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'ramadan': 'Bu gece teravih, imsaktan önce sahur. Ramazan orucunu inanarak ve sevabını umarak tutanın geçmiş günahları bağışlanır (Buhârî).',
      'dhulHijjah': 'Salih amelin Allah\'a bu on günden daha sevimli olduğu gün yoktur (Buhârî). Tekbir, oruç, sadaka.',
      'arafah': 'Bu günün orucu geçen ve gelecek yılın günahlarına kefarettir (Müslim). Niyetini bu gece et.',
      'eidFitr': 'Fitre\'yi bayram namazından önce ver, bu geceden itibaren tekbir getir.',
      'eidAdha': 'Tekbir getir, sabah bayram namazını kıl, sonra kurbanını kes.',
      'tasua':
          'Peygamber ﷺ Âşûrâ ile birlikte dokuzuncu günü de oruç tutmayı niyet etmişti (Müslim). Âşûrâ ertesi gün.',
      'ashura': 'Âşûrâ orucu geçen yılın günahlarına kefarettir (Müslim). Niyetini bu gece et.',
      'whiteDays': 'Ayın 13, 14 ve 15\'inde oruç: her ay üç gün oruç, bütün yıl oruç tutmak gibidir (Buhârî).',
      'monday':
          'Ameller pazartesi ve perşembe arz edilir; Peygamber ﷺ amelinin oruçluyken arz edilmesini severdi (Tirmizî).',
      'thursday':
          'Ameller pazartesi ve perşembe arz edilir; Peygamber ﷺ amelinin oruçluyken arz edilmesini severdi (Tirmizî).',
      'jumuah': 'Gusül al, erken git, Kehf sûresini oku ve bugün Peygamber ﷺ\'e bolca salavat getir.',
      'fridayLastHour': 'Cuma gününde her duanın kabul edildiği bir saat vardır (Buhârî). Akşamdan önce şimdi onu ara.',
      'suhoor': 'Sahur yapın, çünkü sahurda bereket vardır (Buhârî). İmsak yaklaşıyor.',
      'iftar': 'İnsanlar iftarı acele ettikçe hayır üzeredir (Buhârî). Orucunu açarken dua et.',
      'laylatAlQadr':
          'Bin aydan daha hayırlı. Namaz kıl ve de ki: Allahümme inneke afüvvün tuhibbü\'l-afve fa\'fu annî.',
      'morningAdhkar': 'Güne Allah\'ın korumasında başlamak için birkaç dakikalık zikir.',
      'eveningAdhkar': 'Akşamdan önce akşam zikirleri. Okumak için dokun.',
      'lastThird': 'Rabbimiz dünya semasına iner ve buyurur: Bana dua eden yok mu, duasını kabul edeyim? (Buhârî)',
      'bedtime': 'Âyetü\'l-Kürsî, Bakara\'nın son iki âyeti ve uyku duası. İki dakika.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'ramadan': 'Ramazan\'ın başlangıcı',
      'dhulHijjah': 'Zilhicce ve Arefe',
      'eid': 'Bayram',
      'ashura': 'Tâsûâ ve Âşûrâ',
      'whiteDays': 'Eyyâm-ı bîd',
      'monThu': 'Pazartesi ve perşembe oruçları',
      'jumuah': 'Cuma sabahı',
      'fridayLastHour': 'Cumanın icabet saati',
      'suhoor': 'Sahur',
      'iftar': 'İftar',
      'laylatAlQadr': 'Son on gecenin tek geceleri',
      'morningAdhkar': 'Sabah zikirleri',
      'eveningAdhkar': 'Akşam zikirleri',
      'lastThird': 'Gecenin son üçte biri',
      'bedtime': 'Uyumadan önce',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remWhen(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'ramadan': 'Ramazan\'ın başladığı gece',
      'dhulHijjah': 'On gün başlarken ve Arefe gecesi',
      'eid': 'Her bayramdan önceki akşam',
      'ashura': 'Muharrem\'in 9 ve 10\'undan önceki akşamlar',
      'whiteDays': 'Her ay 13\'ünden önceki akşam',
      'monThu': 'Pazar ve çarşamba akşamları',
      'jumuah': 'Cuma sabahı',
      'fridayLastHour': 'Cuma, akşamdan önceki son saat',
      'suhoor': 'Ramazan\'da her gün imsaktan önce',
      'iftar': 'Ramazan\'da her gün akşam vakti',
      'laylatAlQadr': '21, 23, 25, 27 ve 29. geceler',
      'morningAdhkar': 'Sabah namazından sonra',
      'eveningAdhkar': 'İkindiden sonra',
      'lastThird': 'Son üçte bir başlarken',
      'bedtime': 'Yatma saatinde',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get remHeroTitle => 'En kıymetli anları kaçırma';

  @override
  String get remHeroBody =>
      'Waqt yalnızca sevabı en büyük vakitlerde hatırlatır: Arefe, Âşûrâ, Kadir Gecesi, her cuma. Her hatırlatma ne yapacağını ve nedenini, kaynağıyla söyler.';

  @override
  String get remTurnOn => 'Hatırlatmaları aç';

  @override
  String get remComingUp => 'Yaklaşan hatırlatmalar';

  @override
  String get remNothingSoon => 'Önümüzdeki ay hiçbir şey yok. Aşağıdan başka hatırlatmalar aç.';

  @override
  String get remPreview => 'Önizleme';

  @override
  String get remTest => 'Bana deneme hatırlatması gönder';

  @override
  String get remTestSent => 'Gönderildi. Bildirimlerine bak.';

  @override
  String get remNow => 'şimdi';

  @override
  String get remGroupSpecial => 'Mübarek günler';

  @override
  String get remGroupFriday => 'Her cuma';

  @override
  String get remGroupRamadan => 'Ramazan\'da';

  @override
  String get remGroupDaily => 'Her gün';

  @override
  String get remDailyNote => 'Varsayılan olarak kapalı, böylece en önemli hatırlatmalar öne çıkar.';

  @override
  String get qiblaFromLabel => 'Kıble yönü';

  @override
  String get qiblaToLeft => 'solunuzda';

  @override
  String get qiblaToRight => 'sağınızda';

  @override
  String qiblaToMakkah(String km) {
    return 'Mekke\'ye $km km';
  }

  @override
  String get qiblaHint => 'Ok yukarıyı gösterip ekran parlayana kadar dönün.';

  @override
  String get deedOnTime => 'Vaktinde kılındı';

  @override
  String get deedJamaah => 'Cemaatle';

  @override
  String get deedQada => 'Kaza edildi';

  @override
  String get deedNotPrayed => 'İşaretlenmedi';

  @override
  String deedPrayedCount(String done) {
    return '5 vakitten $done';
  }

  @override
  String get deedRingHint => 'Kıldıktan sonra Şimdi ekranında namazı işaretleyin. Bunu yalnızca siz görürsünüz.';

  @override
  String deedStreak(String days) {
    return 'Üst üste $days gün beş vakit';
  }

  @override
  String get progressTitle => 'İlerlemeniz';

  @override
  String get progressThisWeek => 'Bu hafta';

  @override
  String get progressBestRun => 'Beş vaktin en uzun serisi';

  @override
  String get progressQada => 'İşaretsiz, kaza (30 gün)';

  @override
  String progressDays(String days) {
    return '$days gün';
  }

  @override
  String get progressReflection => '“Allah’a en sevimli amel, az da olsa devamlı olanıdır.” (Buhârî, Müslim)';

  @override
  String progressOfPrayers(String total) {
    return '$total vakitten';
  }

  @override
  String get progressOnTimeShort => 'vaktinde';

  @override
  String get progressCurrentRun => 'gün üst üste';

  @override
  String get progressByPrayer => 'Her vakit, son 30 gün';

  @override
  String progressHardest(String prayer) {
    return 'Şu an en çok özen isteyen vakit $prayer.';
  }

  @override
  String get progressWeeks => 'Son 12 hafta';

  @override
  String get progressEmpty =>
      'Kıldıktan sonra Şimdi ekranında namaza dokunun. Günleriniz burada dolar, yalnızca bu telefonda.';

  @override
  String get progressEditHint => 'Kıldıklarınızı girmek için bir güne dokunun.';

  @override
  String durShortHm(String h, String m) {
    return '${h}sa ${m}dk';
  }

  @override
  String durShortM(String m) {
    return '${m}dk';
  }

  @override
  String beadLeft(String time) {
    return '$time kaldı';
  }

  @override
  String beadIn(String time) {
    return '$time sonra';
  }

  @override
  String get beadEnded => 'bitti';

  @override
  String get onbWelcomeTitle => 'Her ana uygun dua';

  @override
  String get onbWelcomeBody => 'Hepsi Sünnet\'ten, kaynağıyla.';

  @override
  String get onbWelcomeNote => 'Ücretsiz. Hesap yok, reklam yok.';

  @override
  String get onbBegin => 'Başla';

  @override
  String get onbLanguageTitle => 'Dilini seç';

  @override
  String get onbLanguageBody => 'Dualar hep Arapça kalır.';

  @override
  String get onbPhoneLanguage => 'Telefonunun dili';

  @override
  String get onbContinue => 'Devam';

  @override
  String get onbLocationTitle => 'Nerede namaz kılıyorsun?';

  @override
  String get onbLocationBody => 'Namaz vakitleri ve kıble için. Bu telefonda kalır.';

  @override
  String get onbCityInstead => 'Bunun yerine şehir seç';

  @override
  String get onbRemindersTitle => 'Yalnızca değerli anlar';

  @override
  String get onbRemindersBody => 'Arefe, Aşure, bayram ve cuma. Gereksiz bildirim yok.';

  @override
  String get onbRemindersOn => 'Hatırlatmaları aç';

  @override
  String get onbLater => 'Sonra';

  @override
  String onbStep(int n, int total) {
    return 'Adım $n / $total';
  }

  @override
  String get beadOnTime => 'vaktinde';

  @override
  String get beadJamaah => 'cemaatle';

  @override
  String get beadLate => 'kaza';

  @override
  String get comingUpTitle => 'Sırada';

  @override
  String comingIn(String time) {
    return '$time sonra';
  }

  @override
  String get beadTapToMark => 'işaretle';
}
