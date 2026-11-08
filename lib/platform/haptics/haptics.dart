import 'dart:async';

import 'package:flutter/services.dart';

import '../../core/config/runtime.dart';

/// Haptics played by the phone's vibrator directly (Android), so they are
/// crisp and felt even where the system's touch feedback is soft. Elsewhere
/// they fall back to Flutter's [HapticFeedback].
abstract final class Haptics {
  static const _channel = MethodChannel('waqt/haptics');

  /// The lightest touch: tab changes, steps on a scale.
  static void tick() => _play('tick', HapticFeedback.selectionClick);

  /// A clear, crisp tap: one count on the misbaha.
  static void click() => _play('click', HapticFeedback.mediumImpact);

  /// A firm thud: arriving (facing the Qibla).
  static void heavy() => _play('heavy', HapticFeedback.heavyImpact);

  /// Two quick taps: a set of the dhikr completed.
  static void double() => _play('double', () {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 120), HapticFeedback.heavyImpact);
  });

  /// Three strong pulses: a whole round completed.
  static void success() => _play('success', () {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 120), HapticFeedback.heavyImpact);
    Future.delayed(const Duration(milliseconds: 240), HapticFeedback.heavyImpact);
  });

  static void _play(String kind, void Function() fallback) {
    if (!Runtime.hasPlatformPlugins || !Runtime.isAndroid) {
      fallback();
      return;
    }
    unawaited(_channel.invokeMethod<void>('play', kind).catchError((Object _) => fallback()));
  }
}
