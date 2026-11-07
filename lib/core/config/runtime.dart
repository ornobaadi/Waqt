import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Where the app is running. dart:io's Platform does not exist on the web,
/// so every check goes through here.
abstract final class Runtime {
  /// Under `flutter test`: no network, no platform plugins, no tickers.
  static final bool isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  /// Notifications, the home-screen widget and the battery channel exist
  /// only on the phone.
  static final bool hasPlatformPlugins = !kIsWeb && !isTest;
}
