import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fake-clock override for QA. `null` = real time.
///
/// Stored as an offset from the wall clock so time keeps flowing while faked,
/// which is what you want when watching a moment begin or end.
class FakeClock extends Notifier<Duration?> {
  @override
  Duration? build() => null;

  void jumpTo(DateTime target) => state = target.difference(DateTime.now());
  void shift(Duration by) => state = (state ?? Duration.zero) + by;
  void reset() => state = null;
}

final fakeClockProvider = NotifierProvider<FakeClock, Duration?>(FakeClock.new);

/// The single source of "now" for the whole app. Never call DateTime.now()
/// in features or domain code; read this instead.
DateTime readNow(Duration? offset) => offset == null ? DateTime.now() : DateTime.now().add(offset);

/// Ticks on every wall-clock second boundary.
final nowProvider = StreamProvider<DateTime>((ref) {
  final offset = ref.watch(fakeClockProvider);
  final controller = StreamController<DateTime>();
  Timer? timer;

  void schedule() {
    final now = readNow(offset);
    controller.add(now);
    timer = Timer(Duration(milliseconds: 1000 - now.millisecond), schedule);
  }

  schedule();
  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });
  return controller.stream;
});
