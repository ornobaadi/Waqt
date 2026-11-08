// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Waqt';

  @override
  String get navNow => 'Sekarang';

  @override
  String get navToday => 'Hari ini';

  @override
  String get navDuas => 'Doa';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get prayerFajr => 'Subuh';

  @override
  String get prayerSunrise => 'Terbit';

  @override
  String get prayerDhuhr => 'Zuhur';

  @override
  String get prayerAsr => 'Asar';

  @override
  String get prayerMaghrib => 'Magrib';

  @override
  String get prayerIsha => 'Isya';

  @override
  String get momentNight => 'Malam';

  @override
  String get momentBedtime => 'Menjelang tidur';

  @override
  String get timePending => '–';

  @override
  String get nowLocationTitle => 'Di mana Anda salat?';

  @override
  String get nowLocationBody =>
      'Jadwal salat dihitung di ponsel Anda dari lokasi Anda. Tidak ada yang keluar dari perangkat.';

  @override
  String get todayEmptyTitle => 'Hari Anda, dari waktu ke waktu';

  @override
  String get todayEmptyBody =>
      'Setiap waktu hari ini, dari Subuh hingga sepertiga malam terakhir, akan tampil di sini setelah jadwal salat dihitung.';

  @override
  String get duasEmptyTitle => 'Hanya sumber terverifikasi';

  @override
  String get duasEmptyBody =>
      'Pustaka dibuka setelah setiap teks diperiksa dengan sumber aslinya dan disetujui oleh seorang ulama.';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsLanguageSystem => 'Bahasa perangkat';

  @override
  String get settingsDeveloper => 'Test mode';

  @override
  String get settingsDeveloperHint => 'Fake clock, day jumps and the reference checker';

  @override
  String get settingsAbout => 'Tentang Waqt';

  @override
  String settingsVersion(String version) {
    return 'Versi $version';
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
  String get waqtMorning => 'Pagi';

  @override
  String nextIn(String prayer, String time) {
    return '$prayer dalam $time';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year H';
  }

  @override
  String get hijriMonth1 => 'Muharam';

  @override
  String get hijriMonth2 => 'Safar';

  @override
  String get hijriMonth3 => 'Rabiulawal';

  @override
  String get hijriMonth4 => 'Rabiulakhir';

  @override
  String get hijriMonth5 => 'Jumadilawal';

  @override
  String get hijriMonth6 => 'Jumadilakhir';

  @override
  String get hijriMonth7 => 'Rajab';

  @override
  String get hijriMonth8 => 'Syakban';

  @override
  String get hijriMonth9 => 'Ramadan';

  @override
  String get hijriMonth10 => 'Syawal';

  @override
  String get hijriMonth11 => 'Zulkaidah';

  @override
  String get hijriMonth12 => 'Zulhijah';

  @override
  String get locationUseGps => 'Gunakan lokasi saya';

  @override
  String get locationChooseCity => 'Pilih kota';

  @override
  String get locationLocating => 'Mencari lokasi…';

  @override
  String get gpsServiceOff => 'Lokasi di ponsel ini mati. Nyalakan, atau pilih kota.';

  @override
  String get gpsDenied => 'Izin lokasi ditolak. Anda bisa memilih kota.';

  @override
  String get gpsDeniedForever => 'Izin lokasi diblokir. Izinkan di pengaturan, atau pilih kota.';

  @override
  String get gpsTimeout => 'Lokasi tidak ditemukan. Coba lagi, atau pilih kota.';

  @override
  String get openSettings => 'Buka pengaturan';

  @override
  String get settingsLocation => 'Lokasi';

  @override
  String get settingsNotSet => 'Belum diatur';

  @override
  String get settingsUseGps => 'Gunakan lokasi saat ini';

  @override
  String get settingsGpsSource => 'Dari GPS';

  @override
  String get settingsPrayerTimes => 'Jadwal salat';

  @override
  String get settingsMethod => 'Metode perhitungan';

  @override
  String get settingsRegionalDefault => 'Bawaan untuk wilayah Anda';

  @override
  String get settingsAsr => 'Waktu Asar';

  @override
  String get asrStandard => 'Jumhur';

  @override
  String get asrStandardHint => 'Syafi\'i, Maliki, Hanbali: bayangan sama dengan benda';

  @override
  String get asrHanafi => 'Hanafi';

  @override
  String get asrHanafiHint => 'Bayangan dua kali panjang benda';

  @override
  String get settingsHighLat => 'Aturan lintang tinggi';

  @override
  String get highLatAuto => 'Otomatis';

  @override
  String get highLatAutoHint => 'Sepertujuh malam di atas 48°, tengah malam di bawahnya';

  @override
  String get highLatMiddle => 'Tengah malam';

  @override
  String get highLatSeventh => 'Sepertujuh malam';

  @override
  String get highLatTwilight => 'Sudut senja';

  @override
  String get settingsCalendar => 'Kalender';

  @override
  String get settingsHijriAdjust => 'Penyesuaian tanggal Hijriah';

  @override
  String get hijriAdjustHint => 'Sesuaikan dengan rukyat hilal di tempat Anda';

  @override
  String get hijriOffsetNone => 'Tidak ada';

  @override
  String hijriOffsetDays(String value) {
    return '$value hr';
  }

  @override
  String get settingsAttribution => 'Data kota © GeoNames, CC BY 4.0. Jadwal salat dihitung di perangkat.';

  @override
  String get citySearchHint => 'Cari kota';

  @override
  String cityNoResults(String query) {
    return 'Tidak ada kota yang cocok dengan “$query”';
  }

  @override
  String get methodMwl => 'Liga Muslim Dunia';

  @override
  String get methodIsna => 'ISNA, Amerika Utara';

  @override
  String get methodEgypt => 'Otoritas Survei Umum Mesir';

  @override
  String get methodKarachi => 'Universitas Ilmu Islam, Karachi';

  @override
  String get methodUmmAlQura => 'Umm al-Qura, Makkah';

  @override
  String get methodDubai => 'Dubai';

  @override
  String get methodQatar => 'Qatar';

  @override
  String get methodKuwait => 'Kuwait';

  @override
  String get methodSingapore => 'Singapura, Malaysia, Indonesia (Kemenag)';

  @override
  String get methodTurkey => 'Diyanet, Turki';

  @override
  String get methodTehran => 'Institut Geofisika, Teheran';

  @override
  String get methodMoonsighting => 'Moonsighting Committee';

  @override
  String get timesEstimated =>
      'Perkiraan. Matahari tidak terbit atau terbenam seperti biasa di sini hari ini, jadi waktu mengikuti lintang 65°.';

  @override
  String get momentLastThird => 'Sepertiga malam terakhir';

  @override
  String get momentFridayLastHour => 'Saat terakhir hari Jumat';

  @override
  String momentAdhanIqamah(String prayer) {
    return 'Sebelum iqamah $prayer';
  }

  @override
  String momentAfterSalah(String prayer) {
    return 'Setelah $prayer';
  }

  @override
  String get momentRestrictedSunrise => 'Matahari terbit';

  @override
  String get momentRestrictedZawal => 'Matahari di puncak';

  @override
  String get momentRestrictedSunset => 'Matahari terbenam';

  @override
  String get momentDuha => 'Duha';

  @override
  String get momentMorningAdhkar => 'Zikir pagi';

  @override
  String get momentEveningAdhkar => 'Zikir petang';

  @override
  String get kindRestricted => 'Waktu terlarang salat sunah';

  @override
  String get rightNow => 'Saat ini';

  @override
  String until(String time) {
    return 'hingga $time';
  }

  @override
  String get comingUp => 'Berikutnya';

  @override
  String startsAt(String time) {
    return 'pukul $time';
  }

  @override
  String startsIn(String time) {
    return 'dalam $time';
  }

  @override
  String get timelineNow => 'Sekarang';

  @override
  String get debugJump => 'Jump to moment';

  @override
  String get statusDraft => 'Draf';

  @override
  String get statusChecked => 'Diperiksa';

  @override
  String get draftNotice => 'Draf belum diperiksa, hanya tampil di versi pengembangan';

  @override
  String get collectionQuran => 'Al-Qur\'an';

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
  String get sheetSource => 'Sumber';

  @override
  String get sheetNarrator => 'Diriwayatkan oleh';

  @override
  String get sheetGrade => 'Derajat';

  @override
  String get sheetGradedBy => 'Dinilai oleh';

  @override
  String get sheetTranslation => 'Terjemahan';

  @override
  String get sheetReview => 'Pemeriksaan';

  @override
  String sheetOpen(String host) {
    return 'Buka di $host';
  }

  @override
  String get sheetTextPending => 'Teks akan muncul di sini setelah rujukan ini diperiksa dengan sumber aslinya.';

  @override
  String get statusApproved => 'Disetujui ulama';

  @override
  String get gradeSahih => 'Sahih';

  @override
  String get gradeHasan => 'Hasan';

  @override
  String reviewCheckedBy(String name) {
    return 'Diperiksa oleh $name';
  }

  @override
  String reviewApprovedBy(String name) {
    return 'Disetujui oleh $name';
  }

  @override
  String checklistProgress(String done, String total) {
    return '$done dari $total';
  }

  @override
  String get checklistTitleBedtime => 'Sebelum tidur';

  @override
  String get checklistTitleJumuah => 'Jumat';

  @override
  String get momentJumuah => 'Jumat';

  @override
  String get librarySearch => 'Cari doa dan rujukan';

  @override
  String libraryNoMatch(String query) {
    return 'Tidak ada hasil untuk “$query”';
  }

  @override
  String libraryCount(String count) {
    return '$count item';
  }

  @override
  String get libraryOther => 'Lainnya';

  @override
  String get momentLastThirdShort => 'Sepertiga akhir';

  @override
  String reminderBody(String time, String place) {
    return '$time · $place';
  }

  @override
  String get widgetEmptyBody => 'Buka Waqt untuk mengatur lokasi';

  @override
  String get notifTitle => 'Pengingat';

  @override
  String get notifHint => 'Arafah, Asyura, Jumat, Ramadan, dan lainnya';

  @override
  String get notifPermission => 'Notifikasi';

  @override
  String get notifAllowed => 'Diizinkan';

  @override
  String get notifAllow => 'Izinkan';

  @override
  String get notifExact => 'Tepat waktu';

  @override
  String get notifExactHint => 'Agar pengingat salat datang tepat pada menitnya';

  @override
  String get notifBattery => 'Optimasi baterai';

  @override
  String get notifBatteryOk => 'Tidak dibatasi';

  @override
  String get notifBatteryFix => 'Buka pengaturan';

  @override
  String get notifBatteryHint =>
      'Beberapa ponsel menghentikan pengingat di latar belakang. Atur Waqt ke Tidak dibatasi.';

  @override
  String notifBatteryHintOem(String maker) {
    return 'Ponsel $maker sering menghentikan pengingat di latar belakang. Atur Waqt ke Tidak dibatasi.';
  }

  @override
  String get notifPrayers => 'Waktu salat';

  @override
  String get notifMoments => 'Momen';

  @override
  String get notifSound => 'Putar suara';

  @override
  String get notifSoundHint => 'Jika mati, semua pengingat tanpa suara';

  @override
  String notifScheduled(String count, String date) {
    return '$count pengingat dijadwalkan hingga $date';
  }

  @override
  String get notifNone => 'Tidak ada pengingat terjadwal';

  @override
  String get notifStatus => 'Status';

  @override
  String get setupCardTitle => 'Biarkan Waqt mengingatkanmu';

  @override
  String get setupCardBody =>
      'Malam sebelum Arafah, Asyura atau hari raya, dan setiap Jumat: apa yang dilakukan, dan mengapa.';

  @override
  String get setupCardAction => 'Nyalakan';

  @override
  String get setupCardDismiss => 'Nanti saja';

  @override
  String get momentLaylatAlQadr => 'Malam ganjil sepuluh terakhir';

  @override
  String get momentSuhoor => 'Sahur';

  @override
  String get momentIftar => 'Berbuka';

  @override
  String get occEidAlFitr => 'Idulfitri';

  @override
  String get occEidAlAdha => 'Iduladha';

  @override
  String get occArafah => 'Hari Arafah';

  @override
  String get occTashreeq => 'Hari Tasyrik';

  @override
  String get occAshura => 'Asyura';

  @override
  String get occTasua => 'Tasua';

  @override
  String get occLastTen => 'Sepuluh malam terakhir';

  @override
  String occRamadan(String day) {
    return 'Ramadan $day';
  }

  @override
  String get occFirstTen => 'Sepuluh hari pertama Zulhijah';

  @override
  String get occBid => 'Ayyamul Bidh';

  @override
  String get occMonday => 'Puasa Senin';

  @override
  String get occThursday => 'Puasa Kamis';

  @override
  String get counterTitle => 'Penghitung';

  @override
  String get counterTap => 'Ketuk di mana saja untuk menghitung';

  @override
  String get counterReset => 'Atur ulang';

  @override
  String counterRound(String n) {
    return 'Putaran $n';
  }

  @override
  String get counterTarget => 'Butir per putaran';

  @override
  String get counterOpen => 'Penghitung tasbih';

  @override
  String get reportContent => 'Laporkan masalah pada teks ini';

  @override
  String get reportProblem => 'Laporkan masalah';

  @override
  String get reportProblemHint => 'Membuka draf email. Anda melihat semuanya sebelum dikirim.';

  @override
  String get privacyTitle => 'Privasi';

  @override
  String get privacyBody => 'Semuanya dihitung di ponsel ini. Waqt tanpa akun, iklan, atau analitik.';

  @override
  String placeTime(String city) {
    return 'Waktu $city';
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
    return 'sisa $time';
  }

  @override
  String windowPreferred(String time) {
    return 'sebaiknya sebelum $time';
  }

  @override
  String durHm(String h, String m) {
    return '$h j $m mnt';
  }

  @override
  String durM(String m) {
    return '$m mnt';
  }

  @override
  String get counterChoose => 'Ganti zikir';

  @override
  String counterStep(String n, String total) {
    return 'Langkah $n dari $total';
  }

  @override
  String get counterFree => 'Hitung bebas';

  @override
  String get counterFreeHint => 'Hitung apa saja dengan target sendiri';

  @override
  String get counterAfterSalah => 'Setelah salat: 33 · 33 · 34';

  @override
  String get counterHaptics => 'Getar setiap hitungan';

  @override
  String get counterAfterSalahName => 'Setelah salat';

  @override
  String get librarySearchAll => 'Cari hadis dan doa';

  @override
  String get scopeDuas => 'Doa';

  @override
  String get scopeHadith => 'Hadis';

  @override
  String get librarySituations => 'Semua keadaan';

  @override
  String get libraryForNow => 'Sekarang';

  @override
  String duaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count doa', one: '1 doa');
    return '$_temp0';
  }

  @override
  String get libraryPreparing => 'Menyiapkan pencarian hadis. Ini hanya sekali.';

  @override
  String get libraryRefine => 'Menampilkan 60 pertama. Tambah kata untuk mempersempit.';

  @override
  String get sourceHisn =>
      'Hisn al-Muslim by Sa\'id bin Ali bin Wahf al-Qahtani. Text, transliteration and translation as published on sunnah.com, via open-hadith-data.';

  @override
  String get sourceHadith =>
      'Arabic and English as published on sunnah.com, via open-hadith-data. Grades as given by the source.';

  @override
  String hisnNumber(String n) {
    return 'Hisnul Muslim $n';
  }

  @override
  String get copyText => 'Salin';

  @override
  String get copied => 'Disalin';

  @override
  String get openSource => 'Buka sumber';

  @override
  String get readingTitle => 'Ukuran bacaan';

  @override
  String get readingHint => 'Arab, transliterasi dan arti, masing-masing';

  @override
  String get readingArabic => 'Arab';

  @override
  String get readingTransliteration => 'Transliterasi';

  @override
  String get readingMeaning => 'Arti';

  @override
  String stripLeft(String time, String prayer) {
    return '$time hingga $prayer';
  }

  @override
  String get dayGuideToday => 'Sunnah hari ini';

  @override
  String fastToday(String day) {
    return 'Puasa sunnah hari ini · $day';
  }

  @override
  String fastTomorrow(String day) {
    return 'Puasa besok · $day';
  }

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get calendarLegendGuide => 'Ada panduan';

  @override
  String get calendarLegendFast => 'Puasa sunnah';

  @override
  String get calendarNote =>
      'Tanggal mengikuti Umm al-Qura dengan penyesuaian Hijriah Anda. Pada tanggal 29 Syakban, Ramadan dan Zulkaidah, Beranda menanyakan apakah hilal terlihat.';

  @override
  String sightingTitle(String month) {
    return 'Apakah hilal $month terlihat di tempat Anda?';
  }

  @override
  String get sightingBody =>
      'Jawaban Anda menggeser kalender agar Ramadan, Idul Fitri dan Arafah jatuh pada hari yang dijalankan komunitas Anda.';

  @override
  String sightingSeen(String month) {
    return 'Terlihat: $month dimulai';
  }

  @override
  String get sightingNotSeen => 'Tidak terlihat: 30 hari';

  @override
  String get sightingUnsure => 'Tidak yakin';

  @override
  String get ramadanSuhoor => 'Sahur berakhir';

  @override
  String get ramadanIftar => 'Buka puasa';

  @override
  String ramadanIn(String time) {
    return 'dalam $time';
  }

  @override
  String get ramadanDone => 'selesai';

  @override
  String announceTitle(String month) {
    return 'Malam ini menentukan $month';
  }

  @override
  String announceBegins(String month, String authority) {
    return 'Menurut $authority, $month dimulai besok.';
  }

  @override
  String announceThirty(String month, String authority) {
    return 'Menurut $authority, $month genap 30 hari: besok tanggal 30.';
  }

  @override
  String get announceOffline => 'Luring: menampilkan tanggal unduhan terakhir. Waqt memeriksa lagi saat tersambung.';

  @override
  String announceChecking(String time) {
    return 'Waqt memeriksa pengumuman tiap 30 menit malam ini. Terakhir $time.';
  }

  @override
  String get authoritySaudi => 'Dewan Peradilan Tinggi Saudi';

  @override
  String get authorityDiyanet => 'Diyanet (Turki)';

  @override
  String get authorityLocal => 'Rukyat lokal';

  @override
  String get authoritySaudiHint => 'Rukyat yang diumumkan, diperbarui daring';

  @override
  String get authorityDiyanetHint => 'Kalender resmi Turki, diperbarui daring';

  @override
  String get authorityLocalHint => 'Umm al-Qura; tanggal 29 Anda menjawab apakah hilal terlihat';

  @override
  String calendarSourceLine(String authority, String time) {
    return '$authority · diperiksa $time';
  }

  @override
  String get calendarSourceLocal =>
      'Umm al-Qura dengan penyesuaian Anda. Tanggal 29 Syakban, Ramadan dan Zulkaidah, Beranda menanyakan rukyat.';

  @override
  String announceUnknown(String month) {
    return 'Pengumuman belum sampai ke Waqt. Jika hilal terlihat malam ini, $month dimulai besok; jika tidak, bulan ini genap 30 hari.';
  }

  @override
  String get adjustTitle => 'Sesuaikan waktu';

  @override
  String get adjustRowHint => 'Cocokkan dengan jadwal lokal atau masjid';

  @override
  String get adjustNone => 'Tidak ada';

  @override
  String adjustSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count waktu', one: '1 waktu');
    return '$_temp0';
  }

  @override
  String get adjustHint =>
      'Waktu dihitung untuk posisi tepat Anda. Jika jadwal lokal (misalnya Kemenag atau masjid Anda) berbeda satu-dua menit, cocokkan di sini.';

  @override
  String get adjustNote =>
      'Sahur berakhir saat Subuh dan berbuka saat Magrib, jadi menyesuaikannya juga menggeser sahur dan berbuka. Pengingat dan widget mengikuti.';

  @override
  String get adjustEarlier => '1 menit lebih awal';

  @override
  String get adjustLater => '1 menit lebih lambat';

  @override
  String get momentTaraweeh => 'Tarawih';

  @override
  String get showLess => 'Lebih sedikit';

  @override
  String showAll(int count) {
    return 'Tampilkan semua $count';
  }

  @override
  String get hadithUnavailable => 'Pencarian hadis tidak tersedia di sini. Berfungsi di aplikasi Android.';

  @override
  String get hadithLibraryTitle => 'Pustaka hadis';

  @override
  String get hadithLibraryBody =>
      'Ensiklopedia HadeethEnc dalam bahasa Anda: hadis sahih beserta teks Arab, derajat, dan penjelasannya, bisa dicari luring. Cukup diunduh sekali.';

  @override
  String hadithLibraryDownload(String mb) {
    return 'Unduh ($mb MB)';
  }

  @override
  String hadithLibraryProgress(int percent) {
    return 'Mengunduh… $percent%';
  }

  @override
  String get hadithLibraryFailed => 'Unduhan belum selesai. Periksa koneksi Anda.';

  @override
  String get hadithLibraryRetry => 'Coba lagi';

  @override
  String get hadithLibraryNote =>
      'Dari HadeethEnc.com, tanpa diubah. Beranda, daftar amalan, dan penghitung tetap berfungsi tanpanya.';

  @override
  String counterToday(String count) {
    return 'Hari ini $count';
  }

  @override
  String get counterTodayTitle => 'Diucapkan hari ini';

  @override
  String get counterTodayAll => 'Semua zikir';

  @override
  String get counterResetRound => 'Ulangi putaran ini';

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
  String get counterAddOwn => 'Tambah zikir sendiri';

  @override
  String get counterOwnName => 'Yang akan Anda ucapkan';

  @override
  String get counterOwnArabic => 'Arab (opsional)';

  @override
  String get counterOwnTarget => 'Berapa kali';

  @override
  String get counterSave => 'Simpan';

  @override
  String get counterRemove => 'Hapus';

  @override
  String get counterSectionReward => 'Zikir dengan keutamaan';

  @override
  String get counterSectionYours => 'Zikir Anda';

  @override
  String get sheetExplanation => 'Penjelasan';

  @override
  String get sheetEnglishOriginal => 'Inggris (sunnah.com)';

  @override
  String sourceHadeethEnc(String date) {
    return 'Terjemahan dan penjelasan: HadeethEnc.com, tanpa diubah (diambil $date).';
  }

  @override
  String get openHadeethEnc => 'HadeethEnc';

  @override
  String heNotTranslated(String language) {
    return 'HadeethEnc belum menerjemahkan hadis ini ke $language, jadi teks Arabnya yang ditampilkan.';
  }

  @override
  String get libraryAllTopics => 'Semua topik';

  @override
  String get qiblaTitle => 'Kiblat';

  @override
  String qiblaFrom(String city) {
    return 'Dari $city';
  }

  @override
  String get qiblaFacing => 'Anda menghadap kiblat';

  @override
  String get qiblaTurnRight => 'Putar ke kanan';

  @override
  String get qiblaTurnLeft => 'Putar ke kiri';

  @override
  String get qiblaDirection => 'Arah';

  @override
  String qiblaBearing(String deg) {
    return '$deg° dari utara';
  }

  @override
  String get qiblaDistance => 'Jarak ke Ka\'bah';

  @override
  String qiblaKm(String km) {
    return '$km km';
  }

  @override
  String get qiblaHoldFlat => 'Letakkan ponsel mendatar';

  @override
  String get qiblaCalibrate => 'Jika arahnya bergeser, gerakkan ponsel membentuk angka 8, jauh dari logam dan magnet.';

  @override
  String qiblaNoCompass(String deg) {
    return 'Perangkat ini tidak punya kompas. Hadap $deg° dari utara dengan patokan bangunan atau matahari.';
  }

  @override
  String get qiblaNoPlace => 'Pilih kota untuk menemukan kiblat.';

  @override
  String get qiblaNorthShort => 'U';

  @override
  String get footerHandcrafted => 'DIBUAT DENGAN SEPENUH HATI OLEH';

  @override
  String get footerSignatureLabel => 'Tanda tangan Ornob Aadi';

  @override
  String footerVersion(String version) {
    return 'WAQT · BETA $version';
  }

  @override
  String get footerTagline => 'OFFLINE · TANPA IKLAN · TANPA PELACAKAN';

  @override
  String get footerDuaRequest => 'Ingat saya dalam doa Anda.';

  @override
  String remTitle(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'ramadan': '🌙 Ramadan dimulai malam ini',
      'dhulHijjah': '🕋 Sepuluh hari terbaik dimulai',
      'arafah': '🤲 Besok Hari Arafah',
      'eidFitr': '🎉 Besok Idulfitri',
      'eidAdha': '🐑 Besok Iduladha',
      'tasua': '🗓️ Puasa Tasu\'a besok',
      'ashura': '🌊 Besok hari Asyura',
      'whiteDays': '🌕 Ayyamul Bidh mulai besok',
      'monday': '🗓️ Besok puasa Senin',
      'thursday': '🗓️ Besok puasa Kamis',
      'jumuah': '🕌 Jumat Mubarak',
      'fridayLastHour': '🤲 Waktu mustajab hari Jumat',
      'suhoor': '🌙 Waktunya sahur',
      'iftar': '🌅 Waktunya berbuka',
      'laylatAlQadr': '✨ Malam ini mungkin Lailatulqadar',
      'morningAdhkar': '☀️ Zikir pagi',
      'eveningAdhkar': '🌇 Zikir petang',
      'lastThird': '🌌 Sepertiga malam terakhir',
      'bedtime': '😴 Sebelum tidur',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remBody(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'ramadan': 'Tarawih malam ini, sahur sebelum Subuh. Siapa berpuasa Ramadan karena iman dan mengharap pahala, diampuni dosanya yang lalu (Bukhari).',
      'dhulHijjah': 'Tidak ada hari yang amal saleh lebih dicintai Allah daripada sepuluh hari ini (Bukhari). Takbir, puasa, sedekah.',
      'arafah': 'Puasanya menghapus dosa setahun lalu dan setahun yang akan datang (Muslim). Niatkan malam ini.',
      'eidFitr': 'Tunaikan zakat fitrah sebelum salat Id, dan bertakbirlah sejak malam ini.',
      'eidAdha': 'Bertakbirlah, salat Id di pagi hari, lalu sembelih kurbanmu.',
      'tasua': 'Nabi ﷺ berniat puasa tanggal 9 bersama Asyura (Muslim). Asyura jatuh sehari setelahnya.',
      'ashura': 'Puasa Asyura menghapus dosa setahun yang lalu (Muslim). Niatkan malam ini.',
      'whiteDays': 'Puasa tanggal 13, 14 dan 15: tiga hari tiap bulan seperti puasa setahun penuh (Bukhari).',
      'monday': 'Amal diperlihatkan pada hari Senin dan Kamis, dan Nabi ﷺ suka amalnya diperlihatkan saat berpuasa (Tirmidzi).',
      'thursday': 'Amal diperlihatkan pada hari Senin dan Kamis, dan Nabi ﷺ suka amalnya diperlihatkan saat berpuasa (Tirmidzi).',
      'jumuah': 'Mandi, berangkat lebih awal, baca surah al-Kahfi dan perbanyak selawat kepada Nabi ﷺ hari ini.',
      'fridayLastHour':
          'Pada hari Jumat ada satu waktu ketika setiap doa dikabulkan (Bukhari). Carilah sekarang, sebelum Magrib.',
      'suhoor': 'Bersahurlah, karena dalam sahur ada berkah (Bukhari). Subuh sebentar lagi.',
      'iftar': 'Manusia senantiasa dalam kebaikan selama menyegerakan berbuka (Bukhari). Berdoalah saat berbuka.',
      'laylatAlQadr': 'Lebih baik dari seribu bulan (QS. Al-Qadr: 3). Salatlah, dan ucapkan: Allahumma innaka ʿafuwwun tuhibbul-ʿafwa faʿfu ʿanni (Tirmidzi).',
      'morningAdhkar': 'Beberapa menit zikir untuk memulai hari dalam lindungan Allah.',
      'eveningAdhkar': 'Zikir petang, sebelum Magrib. Ketuk untuk membacanya.',
      'lastThird':
          'Rabb kita turun ke langit dunia dan berfirman: siapa yang berdoa kepada-Ku, akan Aku kabulkan? (Bukhari)',
      'bedtime': 'Ayat Kursi, dua ayat terakhir al-Baqarah dan doa tidur. Dua menit.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'ramadan': 'Awal Ramadan',
      'dhulHijjah': 'Zulhijah dan Arafah',
      'eid': 'Hari raya',
      'ashura': 'Tasu\'a dan Asyura',
      'whiteDays': 'Ayyamul Bidh',
      'monThu': 'Puasa Senin dan Kamis',
      'jumuah': 'Pagi hari Jumat',
      'fridayLastHour': 'Waktu mustajab Jumat',
      'suhoor': 'Sahur',
      'iftar': 'Berbuka',
      'laylatAlQadr': 'Malam ganjil sepuluh terakhir',
      'morningAdhkar': 'Zikir pagi',
      'eveningAdhkar': 'Zikir petang',
      'lastThird': 'Sepertiga malam terakhir',
      'bedtime': 'Sebelum tidur',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String remWhen(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'ramadan': 'Malam Ramadan dimulai',
      'dhulHijjah': 'Saat sepuluh hari dimulai, dan malam Arafah',
      'eid': 'Petang sebelum setiap hari raya',
      'ashura': 'Petang sebelum tanggal 9 dan 10 Muharam',
      'whiteDays': 'Petang sebelum tanggal 13, tiap bulan',
      'monThu': 'Minggu dan Rabu petang',
      'jumuah': 'Jumat pagi',
      'fridayLastHour': 'Jumat, satu jam terakhir sebelum Magrib',
      'suhoor': 'Sebelum Subuh, tiap hari Ramadan',
      'iftar': 'Saat Magrib, tiap hari Ramadan',
      'laylatAlQadr': 'Malam ke-21, 23, 25, 27 dan 29',
      'morningAdhkar': 'Setelah Subuh',
      'eveningAdhkar': 'Setelah Asar',
      'lastThird': 'Saat sepertiga terakhir dimulai',
      'bedtime': 'Saat waktu tidurmu',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get remHeroTitle => 'Jangan lewatkan saat-saat yang paling berharga';

  @override
  String get remHeroBody =>
      'Waqt hanya mengingatkan di waktu-waktu yang paling besar pahalanya: Arafah, Asyura, Lailatulqadar, setiap Jumat. Tiap pengingat menjelaskan apa yang dilakukan dan mengapa, beserta sumbernya.';

  @override
  String get remTurnOn => 'Nyalakan pengingat';

  @override
  String get remComingUp => 'Pengingat berikutnya';

  @override
  String get remNothingSoon => 'Tidak ada dalam sebulan ke depan. Nyalakan pengingat lain di bawah.';

  @override
  String get remPreview => 'Pratinjau';

  @override
  String get remTest => 'Kirim pengingat uji coba';

  @override
  String get remTestSent => 'Terkirim. Lihat notifikasimu.';

  @override
  String get remNow => 'sekarang';

  @override
  String get remGroupSpecial => 'Hari-hari istimewa';

  @override
  String get remGroupFriday => 'Setiap Jumat';

  @override
  String get remGroupRamadan => 'Saat Ramadan';

  @override
  String get remGroupDaily => 'Setiap hari';

  @override
  String get remDailyNote => 'Mati secara bawaan, agar pengingat yang paling penting tetap menonjol.';

  @override
  String get qiblaFromLabel => 'Kiblat dari';

  @override
  String get qiblaToLeft => 'ke kiri';

  @override
  String get qiblaToRight => 'ke kanan';

  @override
  String qiblaToMakkah(String km) {
    return '$km km ke Makkah';
  }

  @override
  String get qiblaHint => 'Putar sampai panah menunjuk ke atas dan layar menyala.';

  @override
  String get deedOnTime => 'Tepat waktu';

  @override
  String get deedJamaah => 'Berjamaah';

  @override
  String get deedQada => 'Diqadha';

  @override
  String get deedNotPrayed => 'Belum ditandai';

  @override
  String deedPrayedCount(String done) {
    return '$done dari 5 salat';
  }

  @override
  String get deedRingHint => 'Centang salat di Sekarang setelah Anda menunaikannya. Hanya Anda yang melihatnya.';

  @override
  String deedStreak(String days) {
    return '$days hari berturut-turut lima waktu';
  }

  @override
  String get progressTitle => 'Perkembangan Anda';

  @override
  String get progressThisWeek => 'Minggu ini';

  @override
  String get progressBestRun => 'Rangkaian terpanjang lima waktu';

  @override
  String get progressQada => 'Belum ditandai, untuk diqadha (30 hari)';

  @override
  String progressDays(String days) {
    return '$days hari';
  }

  @override
  String get progressReflection =>
      '“Amalan yang paling dicintai Allah adalah yang paling rutin meskipun sedikit.” (Bukhari, Muslim)';

  @override
  String progressOfPrayers(String total) {
    return 'dari $total salat';
  }

  @override
  String get progressOnTimeShort => 'tepat waktu';

  @override
  String get progressCurrentRun => 'hari berturut-turut';

  @override
  String get progressByPrayer => 'Tiap salat, 30 hari terakhir';

  @override
  String progressHardest(String prayer) {
    return '$prayer paling perlu dijaga saat ini.';
  }

  @override
  String get progressWeeks => '12 minggu terakhir';

  @override
  String get progressEmpty =>
      'Ketuk salat di Sekarang setelah Anda menunaikannya. Hari-hari Anda terisi di sini, hanya di ponsel ini.';

  @override
  String get progressEditHint => 'Ketuk sebuah hari untuk mengisi salat Anda.';

  @override
  String durShortHm(String h, String m) {
    return '${h}j ${m}m';
  }

  @override
  String durShortM(String m) {
    return '${m}m';
  }

  @override
  String beadLeft(String time) {
    return 'sisa $time';
  }

  @override
  String beadIn(String time) {
    return '$time lagi';
  }

  @override
  String get beadEnded => 'selesai';

  @override
  String get onbWelcomeTitle => 'Doa yang tepat untuk setiap saat';

  @override
  String get onbWelcomeBody => 'Semuanya dari Sunnah, lengkap dengan sumbernya.';

  @override
  String get onbWelcomeNote => 'Gratis. Tanpa akun, tanpa iklan.';

  @override
  String get onbBegin => 'Mulai';

  @override
  String get onbLanguageTitle => 'Pilih bahasa Anda';

  @override
  String get onbLanguageBody => 'Doa selalu tetap dalam bahasa Arab.';

  @override
  String get onbPhoneLanguage => 'Bahasa ponsel Anda';

  @override
  String get onbContinue => 'Lanjut';

  @override
  String get onbLocationTitle => 'Di mana Anda salat?';

  @override
  String get onbLocationBody => 'Untuk jadwal salat dan kiblat. Tetap di ponsel ini.';

  @override
  String get onbCityInstead => 'Pilih kota saja';

  @override
  String get onbRemindersTitle => 'Hanya saat-saat yang berarti';

  @override
  String get onbRemindersBody => 'Arafah, Asyura, Id, dan Jumat. Tanpa gangguan.';

  @override
  String get onbRemindersOn => 'Nyalakan pengingat';

  @override
  String get onbLater => 'Nanti saja';

  @override
  String onbStep(int n, int total) {
    return 'Langkah $n dari $total';
  }

  @override
  String get beadOnTime => 'tepat waktu';

  @override
  String get beadJamaah => 'berjamaah';

  @override
  String get beadLate => 'qada';

  @override
  String get comingUpTitle => 'Berikutnya';

  @override
  String comingIn(String time) {
    return '$time lagi';
  }

  @override
  String get beadTapToMark => 'tandai';
}
