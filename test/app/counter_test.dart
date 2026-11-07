import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqt/core/clock/clock.dart';
import 'package:waqt/data/user/user_prefs.dart';
import 'package:waqt/features/counter/counter_screen.dart';

void main() {
  late SharedPreferences prefs;

  Future<ProviderContainer> container() async =>
      ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('count survives leaving the app; reset clears the round, not today', () async {
    var c = await container();
    const after = 'after_salah';
    c.read(counterProvider.notifier).choose(after);
    for (var i = 0; i < 40; i++) {
      c.read(counterProvider.notifier).tap();
    }
    expect(c.read(counterProvider).step, 1); // 33 SubhanAllah, then 7 Alhamdulillah
    expect(c.read(counterProvider).count, 7);
    c.dispose();

    c = await container(); // "reopened"
    expect(c.read(counterProvider).count, 7);
    expect(c.read(counterProvider).today, {'subhanallah': 33, 'alhamdulillah': 7});

    c.read(counterProvider.notifier).reset();
    expect(c.read(counterProvider).count, 0);
    expect(c.read(counterProvider).step, 0);
    expect(c.read(counterProvider).todayTotal, 40);
  });

  test('switching dhikr keeps each one where it was', () async {
    final c = await container();
    final n = c.read(counterProvider.notifier);
    n.choose('istighfar');
    for (var i = 0; i < 12; i++) {
      n.tap();
    }
    n.choose('salawat');
    n.tap();
    n.choose('istighfar');
    expect(c.read(counterProvider).count, 12);
    expect(c.read(counterProvider).today, {'istighfar': 12, 'salawat': 1});
  });

  test('a finished set starts again; a new day starts today at zero', () async {
    final c = await container();
    final n = c.read(counterProvider.notifier);
    n.choose('after_salah');
    for (var i = 0; i < 100; i++) {
      n.tap();
    }
    expect(c.read(counterProvider).finished, isTrue);
    n.tap();
    expect((c.read(counterProvider).step, c.read(counterProvider).count), (0, 1));
    expect(c.read(counterProvider).todayTotal, 101);

    c.read(fakeClockProvider.notifier).shift(const Duration(days: 1));
    n.tap();
    expect(c.read(counterProvider).todayTotal, 1);
  });
}
