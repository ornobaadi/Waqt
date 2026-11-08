import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/config/runtime.dart';
import '../../data/user/user_prefs.dart';
import '../../domain/qibla/qibla.dart';

/// One compass reading: where the phone points (degrees from true north when
/// the platform can say), how far the screen is from flat, and the sensor's
/// own estimate of its error (null when unknown).
class Heading {
  const Heading(this.degrees, this.tilt, {this.accuracy});
  final double degrees;
  final double tilt;
  final double? accuracy;

  /// The sensor itself says the reading may be off by a lot: worth a figure eight.
  bool get needsCalibration => (accuracy ?? 0) > 25;
}

const _channel = EventChannel('waqt/heading');

/// Live heading while someone listens. On Android this is the fused
/// rotation-vector sensor (gyroscope + accelerometer + magnetometer) at game
/// rate, corrected to true north for the chosen place: fast and steady. The
/// screen smooths it per frame, so nothing is filtered here. Phones without
/// that sensor fall back to magnetometer maths.
final headingProvider = StreamProvider.autoDispose<Heading>((ref) {
  if (!Runtime.hasPlatformPlugins) return const Stream.empty();
  final place = ref.watch(userPrefsProvider.select((p) => p.place));
  final out = StreamController<Heading>();
  StreamSubscription<Object?>? native;
  List<StreamSubscription<Object?>> fallback = const [];

  native = _channel
      .receiveBroadcastStream({'lat': ?place?.latitude, 'lng': ?place?.longitude})
      .listen(
        (e) {
          if (e case [final num h, final num tilt, final num acc]) {
            out.add(Heading(h.toDouble(), tilt.toDouble(), accuracy: acc < 0 ? null : acc.toDouble()));
          }
        },
        onError: (Object e) {
          native?.cancel();
          fallback = _magnetometer(out);
        },
        cancelOnError: true,
      );

  ref.onDispose(() {
    native?.cancel();
    for (final s in fallback) {
      s.cancel();
    }
    out.close();
  });
  return out.stream;
});

/// Magnetic heading from raw accelerometer + magnetometer, for phones with no
/// fused sensor. Lightly smoothed: these sensors are noisy.
List<StreamSubscription<Object?>> _magnetometer(StreamController<Heading> out) {
  List<double>? g;
  double? sx, sy;
  const alpha = 0.35;
  return [
    accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen((e) {
      final now = [e.x, e.y, e.z];
      g = g == null ? now : [for (var i = 0; i < 3; i++) g![i] + 0.3 * (now[i] - g![i])];
    }, onError: (_) {}),
    magnetometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (e) {
        final grav = g;
        if (grav == null) return;
        final h = headingFrom(grav, [e.x, e.y, e.z]);
        if (h == null) return;
        final r = h * math.pi / 180;
        sx = sx == null ? math.sin(r) : sx! + alpha * (math.sin(r) - sx!);
        sy = sy == null ? math.cos(r) : sy! + alpha * (math.cos(r) - sy!);
        out.add(Heading((math.atan2(sx!, sy!) * 180 / math.pi + 360) % 360, tiltOf(grav)));
      },
      onError: (Object e) => out.addError(e),
      cancelOnError: true,
    ),
  ];
}
