import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqt/data/user/deeds_store.dart';
import 'package:waqt/data/user/user_prefs.dart';
import 'package:waqt/domain/deeds/deeds.dart';
import 'package:waqt/domain/prayer/prayer_times_service.dart';

const all = {
  Waqt.fajr: SalahMark.onTime,
  Waqt.dhuhr: SalahMark.onTime,
  Waqt.asr: SalahMark.jamaah,
  Waqt.maghrib: SalahMark.onTime,
  Waqt.isha: SalahMark.qada,
};
const full = DayLog(salah: all);
const three = DayLog(salah: {Waqt.fajr: SalahMark.onTime, Waqt.dhuhr: SalahMark.qada, Waqt.asr: SalahMark.onTime});

void main() {
  final today = DateTime(2026, 11, 8);
  String k(int daysAgo) => DeedStats.dayKey(today.subtract(Duration(days: daysAgo)));

  test('a run of full days counts; today in progress never breaks it', () {
    final s = DeedStats({k(1): full, k(2): full, k(3): full, k(0): three});
    expect(s.streak(today), 3);
  });

  test('never miss twice: one gap is forgiven, two in a row end the run', () {
    final s = DeedStats({k(1): full, k(2): three, k(3): full, k(4): full, k(5): three, k(6): three, k(7): full});
    expect(s.streak(today), 3);
    expect(s.longestStreak(), 3);
  });

  test('on time share, qada owed, fasts', () {
    final s = DeedStats({k(1): full, k(2): three.copyWith(fast: true), k(10): const DayLog(fast: true)});
    expect(s.onTimeShare(today.subtract(const Duration(days: 3)), today), closeTo(6 / 8, 1e-9));
    expect(s.qadaOwed(today.subtract(const Duration(days: 30)), today), 2); // day k(10) had no prayers marked
    expect(s.firstDay, today.subtract(const Duration(days: 10)));
    expect(s.trackedDays(today.subtract(const Duration(days: 30)), today).length, 11);
    expect(s.prayedIn(today.subtract(const Duration(days: 3)), today), 8);
    expect(s.keptShare(Waqt.fajr, today.subtract(const Duration(days: 2)), today.subtract(const Duration(days: 1))), 1);
    expect(
      s.keptShare(Waqt.isha, today.subtract(const Duration(days: 2)), today.subtract(const Duration(days: 1))),
      0.5,
    );
    expect(DeedStats({}).onTimeShare(today, today), isNull);
  });

  test('store: mark, clear, survive restart, months kept apart', () async {
    SharedPreferences.setMockInitialValues({});
    Future<ProviderContainer> c() async {
      final c = ProviderContainer(
        overrides: [sharedPrefsProvider.overrideWithValue(await SharedPreferences.getInstance())],
      );
      addTearDown(c.dispose);
      return c;
    }

    var box = await c();
    final n = box.read(deedsProvider.notifier);
    n.markSalah('2026-10-31', Waqt.isha, SalahMark.onTime);
    n.markSalah('2026-11-01', Waqt.fajr, SalahMark.jamaah);
    n.markSalah('2026-11-01', Waqt.dhuhr, SalahMark.qada);
    n.markSalah('2026-11-01', Waqt.dhuhr, null);
    n.setFast('2026-11-01', true);
    n.setHabit('2026-11-01', 'quran', 4);

    box = await c();
    final logs = box.read(deedsProvider);
    expect(logs['2026-10-31']!.salah, {Waqt.isha: SalahMark.onTime});
    expect(logs['2026-11-01']!.salah, {Waqt.fajr: SalahMark.jamaah});
    expect(logs['2026-11-01']!.fast, isTrue);
    expect(logs['2026-11-01']!.habits, {'quran': 4});
    final sp = await SharedPreferences.getInstance();
    expect(sp.getKeys().where((x) => x.startsWith('deeds.v1.')).toSet(), {'deeds.v1.2026-10', 'deeds.v1.2026-11'});
  });
}
