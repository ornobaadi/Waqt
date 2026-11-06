import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show appFlavor;

enum Flavor { dev, prod }

abstract final class AppConfig {
  /// Keep in step with `version:` in pubspec.yaml.
  static const version = '1.0.0';

  static const Flavor flavor = appFlavor == 'prod' ? Flavor.prod : Flavor.dev;

  /// Debug tools (fake clock, palette override, forced locale) exist only here.
  static bool get debugTools => flavor == Flavor.dev || kDebugMode;
}
