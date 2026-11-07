import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../core/clock/clock.dart';
import '../../domain/hijri/hijri_service.dart';
import '../user/user_prefs.dart';

/// Whose word decides when a Hijri month begins.
enum HijriAuthority {
  /// Saudi Arabia's High Judiciary Council: Umm al-Qura, corrected for
  /// Muharram, Ramadan, Shawwal and Dhul Hijjah after announced sightings.
  saudi('HJCoSA'),

  /// Türkiye's Presidency of Religious Affairs.
  diyanet('DIYANET'),

  /// Local sighting: Umm al-Qura, and on the 29th the app asks whether the
  /// crescent was seen where you are. Works offline.
  local(null);

  const HijriAuthority(this.method);

  /// calendarMethod on api.aladhan.com; null = no download.
  final String? method;
}

class CalendarSyncState {
  const CalendarSyncState({
    this.authority = HijriAuthority.saudi,
    this.table = const MonthTable({}),
    this.checkedAt,
    this.failed = false,
  });
  final HijriAuthority authority;
  final MonthTable table;

  /// When the authority's months were last fetched.
  final DateTime? checkedAt;

  /// The last attempt failed (offline): the cached months, or the
  /// calculated calendar, stay in use.
  final bool failed;

  CalendarSyncState copyWith({HijriAuthority? authority, MonthTable? table, DateTime? checkedAt, bool? failed}) =>
      CalendarSyncState(
        authority: authority ?? this.authority,
        table: table ?? this.table,
        checkedAt: checkedAt ?? this.checkedAt,
        failed: failed ?? this.failed,
      );
}

/// Downloads month starts from api.aladhan.com for the chosen authority, a
/// few months around today, and keeps them for offline use. Nothing about
/// the user is sent: the request names only a Hijri month and the method.
///
/// Checks every 12 hours, and every 30 minutes on the evenings when a month
/// that matters (Ramadan, Shawwal, Dhul Hijjah, Muharram) may begin, so an
/// announced sighting reaches the app the same night.
class CalendarSync extends Notifier<CalendarSyncState> {
  static const _kAuthority = 'hijri.authority.v1', _kTable = 'hijri.table.v1', _kChecked = 'hijri.checked.v1';
  static const host = 'api.aladhan.com';

  /// Replaced in tests.
  @visibleForTesting
  static Future<String> Function(Uri) fetch = _get;

  Timer? _timer;

  @override
  CalendarSyncState build() {
    ref.onDispose(() => _timer?.cancel());
    final sp = ref.read(sharedPrefsProvider);
    final authority = HijriAuthority.values.asNameMap()[sp.getString(_kAuthority)] ?? HijriAuthority.saudi;
    final checked = sp.getInt(_kChecked);
    return CalendarSyncState(
      authority: authority,
      table: authority.method == null ? const MonthTable({}) : decode(sp.getString(_kTable)),
      checkedAt: checked == null ? null : DateTime.fromMillisecondsSinceEpoch(checked),
    );
  }

  void setAuthority(HijriAuthority a) {
    final sp = ref.read(sharedPrefsProvider);
    unawaited(sp.setString(_kAuthority, a.name));
    unawaited(sp.remove(_kTable));
    unawaited(sp.remove(_kChecked));
    state = CalendarSyncState(authority: a);
    unawaited(refresh(force: true));
  }

  /// How long until the next check, from the date as currently known.
  Duration interval(DateTime now) {
    final h = HijriService(table: state.table).dateFor(now);
    final decisive = h.day >= 28 && const {8, 9, 11, 12}.contains(h.month) || h.day <= 1;
    return decisive ? const Duration(minutes: 30) : const Duration(hours: 12);
  }

  /// Fetches if due (or [force]d), then schedules the next check while the
  /// app is open. Failures keep the cached months.
  Future<void> refresh({bool force = false}) async {
    _timer?.cancel();
    final method = state.authority.method;
    if (method == null) return;
    final now = readNow(ref.read(fakeClockProvider));
    final due = force || state.checkedAt == null || now.difference(state.checkedAt!) >= interval(now);
    if (due) {
      try {
        final table = await download(method, now);
        final sp = ref.read(sharedPrefsProvider);
        await sp.setString(_kTable, encode(table));
        await sp.setInt(_kChecked, now.millisecondsSinceEpoch);
        state = state.copyWith(table: table, checkedAt: now, failed: false);
      } on Object catch (e) {
        debugPrint('calendar sync failed: $e');
        state = state.copyWith(failed: true);
      }
    }
    _timer = Timer(interval(now), refresh);
  }

  /// Months from the one before today to two after, by Umm al-Qura's count.
  static Future<MonthTable> download(String method, DateTime now) async {
    final h = HijriCalendar.fromDate(now);
    final months = <(int, int), ({DateTime start, int days})>{};
    for (var i = -1; i <= 2; i++) {
      var m = h.hMonth + i, y = h.hYear;
      if (m < 1) (m, y) = (m + 12, y - 1);
      if (m > 12) (m, y) = (m - 12, y + 1);
      final body = await fetch(Uri.https(host, '/v1/hToGCalendar/$m/$y', {'calendarMethod': method}));
      final days = (jsonDecode(body) as Map<String, Object?>)['data']! as List<Object?>;
      final first = days.first! as Map<String, Object?>;
      final hijri = first['hijri']! as Map<String, Object?>;
      final greg = (first['gregorian']! as Map<String, Object?>)['date']! as String; // DD-MM-YYYY
      final p = greg.split('-').map(int.parse).toList();
      final length = (hijri['month']! as Map<String, Object?>)['days'] as int? ?? days.length;
      if (int.parse('${hijri['day']}') != 1 || length < 29 || length > 30) {
        throw FormatException('unexpected month $m/$y');
      }
      months[(y, m)] = (start: DateTime(p[2], p[1], p[0]), days: length);
    }
    return MonthTable(months);
  }

  static String encode(MonthTable t) => jsonEncode([
    for (final MapEntry(key: (y, m), value: v) in t.months.entries)
      [y, m, v.start.year, v.start.month, v.start.day, v.days],
  ]);

  static MonthTable decode(String? s) {
    if (s == null) return const MonthTable({});
    try {
      return MonthTable({
        for (final r in (jsonDecode(s) as List<Object?>).cast<List<Object?>>())
          (r[0]! as int, r[1]! as int): (start: DateTime(r[2]! as int, r[3]! as int, r[4]! as int), days: r[5]! as int),
      });
    } on Object {
      return const MonthTable({});
    }
  }

  static Future<String> _get(Uri uri) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final req = await client.getUrl(uri);
      final res = await req.close().timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) throw HttpException('HTTP ${res.statusCode}', uri: uri);
      return await res.transform(utf8.decoder).join();
    } finally {
      client.close();
    }
  }
}

final calendarSyncProvider = NotifierProvider<CalendarSync, CalendarSyncState>(CalendarSync.new);

/// Months whose sighting question the user answered (local sighting).
class SightingAnswers extends Notifier<Set<String>> {
  static const _k = 'sighting.answered.v1';

  @override
  Set<String> build() => (ref.read(sharedPrefsProvider).getStringList(_k) ?? const []).toSet();

  void add(String key) {
    state = {...state, key};
    ref.read(sharedPrefsProvider).setStringList(_k, state.toList());
  }
}

final sightingAnswersProvider = NotifierProvider<SightingAnswers, Set<String>>(SightingAnswers.new);

String sightingKey(int year, int month) => '$year-$month';
