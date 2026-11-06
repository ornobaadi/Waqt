import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqt/data/user/checklist.dart';
import 'package:waqt/data/user/user_prefs.dart';
import 'package:waqt/domain/moments/moment.dart';

Future<ProviderContainer> container() async {
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(overrides: [sharedPrefsProvider.overrideWithValue(prefs)]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('toggle, persist, reset on a new prayer day', () async {
    var c = await container();
    final n = c.read(checklistProvider.notifier);
    n.toggle('2026-11-06', MomentId.bedtime, 'a');
    n.toggle('2026-11-06', MomentId.bedtime, 'b');
    n.toggle('2026-11-06', MomentId.bedtime, 'a');
    expect(c.read(checklistProvider).doneFor('2026-11-06', MomentId.bedtime), {'b'});

    c = await container(); // survives restart
    expect(c.read(checklistProvider).doneFor('2026-11-06', MomentId.bedtime), {'b'});
    expect(c.read(checklistProvider).doneFor('2026-11-07', MomentId.bedtime), isEmpty);

    c.read(checklistProvider.notifier).toggle('2026-11-07', MomentId.jumuah, 'x');
    expect(c.read(checklistProvider).doneFor('2026-11-06', MomentId.bedtime), isEmpty);
  });

  test('prayer day key', () => expect(prayerDayKey(DateTime(2026, 3, 5, 4, 50)), '2026-03-05'));
}
