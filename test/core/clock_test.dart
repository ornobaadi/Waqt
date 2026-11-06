import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/clock/clock.dart';

void main() {
  test('fake clock jumps, shifts and resets', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final target = DateTime(2026, 11, 13, 16, 20); // a Friday afternoon
    c.read(fakeClockProvider.notifier).jumpTo(target);
    expect(readNow(c.read(fakeClockProvider)).difference(target).inSeconds.abs(), lessThan(2));

    c.read(fakeClockProvider.notifier).shift(const Duration(hours: 1));
    expect(readNow(c.read(fakeClockProvider)).hour, 17);

    c.read(fakeClockProvider.notifier).reset();
    expect(c.read(fakeClockProvider), isNull);
  });
}
