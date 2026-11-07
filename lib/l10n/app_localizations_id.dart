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
  String get settingsDeveloperHint =>
      'Fake clock, day jumps and the reference checker';

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
  String get gpsServiceOff =>
      'Lokasi di ponsel ini mati. Nyalakan, atau pilih kota.';

  @override
  String get gpsDenied => 'Izin lokasi ditolak. Anda bisa memilih kota.';

  @override
  String get gpsDeniedForever =>
      'Izin lokasi diblokir. Izinkan di pengaturan, atau pilih kota.';

  @override
  String get gpsTimeout =>
      'Lokasi tidak ditemukan. Coba lagi, atau pilih kota.';

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
  String get asrStandardHint =>
      'Syafi\'i, Maliki, Hanbali: bayangan sama dengan benda';

  @override
  String get asrHanafi => 'Hanafi';

  @override
  String get asrHanafiHint => 'Bayangan dua kali panjang benda';

  @override
  String get settingsHighLat => 'Aturan lintang tinggi';

  @override
  String get highLatAuto => 'Otomatis';

  @override
  String get highLatAutoHint =>
      'Sepertujuh malam di atas 48°, tengah malam di bawahnya';

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
  String get settingsAttribution =>
      'Data kota © GeoNames, CC BY 4.0. Jadwal salat dihitung di perangkat.';

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
  String get draftNotice =>
      'Draf belum diperiksa, hanya tampil di versi pengembangan';

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
  String get sheetTextPending =>
      'Teks akan muncul di sini setelah rujukan ini diperiksa dengan sumber aslinya.';

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
  String get notifHint => 'Waktu salat dan momen, sesuai pilihan Anda';

  @override
  String get notifPermission => 'Notifikasi';

  @override
  String get notifAllowed => 'Diizinkan';

  @override
  String get notifAllow => 'Izinkan';

  @override
  String get notifExact => 'Tepat waktu';

  @override
  String get notifExactHint =>
      'Agar pengingat salat datang tepat pada menitnya';

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
  String get setupCardTitle => 'Pengingat lembut';

  @override
  String get setupCardBody =>
      'Pengingat tenang di setiap waktu salat. Anda yang memilih, dan tidak ada yang keluar dari ponsel Anda.';

  @override
  String get setupCardAction => 'Atur';

  @override
  String get setupCardDismiss => 'Nanti';

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
  String get counterOpen => 'Buka penghitung';

  @override
  String get reportContent => 'Laporkan masalah pada teks ini';

  @override
  String get reportProblem => 'Laporkan masalah';

  @override
  String get reportProblemHint =>
      'Membuka draf email. Anda melihat semuanya sebelum dikirim.';

  @override
  String get privacyTitle => 'Privasi';

  @override
  String get privacyBody =>
      'Semuanya dihitung di ponsel ini. Waqt tanpa akun, iklan, atau analitik.';

  @override
  String placeTime(String city) {
    return 'Waktu $city';
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
  String get librarySearchAll => 'Cari doa dan hadis';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doa',
      one: '1 doa',
    );
    return '$_temp0';
  }

  @override
  String get libraryPreparing =>
      'Menyiapkan pencarian hadis. Ini hanya sekali.';

  @override
  String get libraryRefine =>
      'Menampilkan 60 pertama. Tambah kata untuk mempersempit.';

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
}
