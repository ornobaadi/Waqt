import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/config/runtime.dart';
import '../../domain/qibla/qibla.dart';

/// One compass reading: where the top of the phone points, and how flat it is.
class Heading {
  const Heading(this.degrees, this.tilt);
  final double degrees;
  final double tilt;
}

/// Live, smoothed heading while someone listens; null until the first
/// reading. Emits an error when the phone has no magnetometer.
final headingProvider = StreamProvider.autoDispose<Heading>((ref) {
  if (!Runtime.hasPlatformPlugins) return const Stream.empty();
  final out = StreamController<Heading>();
  List<double>? g;
  double? sx, sy; // smoothed unit vector, so 359° → 1° doesn't swing around
  const alpha = 0.18;

  final subs = <StreamSubscription<Object?>>[
    accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen((e) {
      final now = [e.x, e.y, e.z];
      g = g == null ? now : [for (var i = 0; i < 3; i++) g![i] + 0.2 * (now[i] - g![i])];
    }, onError: (_) {}),
    magnetometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen(
      (e) {
        final grav = g;
        if (grav == null) return;
        final h = headingFrom(grav, [e.x, e.y, e.z]);
        if (h == null) return;
        final r = h * math.pi / 180;
        sx = sx == null ? math.sin(r) : sx! + alpha * (math.sin(r) - sx!);
        sy = sy == null ? math.cos(r) : sy! + alpha * (math.cos(r) - sy!);
        final deg = (math.atan2(sx!, sy!) * 180 / math.pi + 360) % 360;
        out.add(Heading(deg, tiltOf(grav)));
      },
      onError: (Object e) => out.addError(e),
      cancelOnError: true,
    ),
  ];
  ref.onDispose(() {
    for (final s in subs) {
      s.cancel();
    }
    out.close();
  });
  return out.stream;
});
