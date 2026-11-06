import 'package:flutter/foundation.dart';

enum Flavor { dev, prod }

/// The build mode is the environment (no Android product flavors):
/// `--profile` / debug = dev, `--release` = prod.
abstract final class AppConfig {
  /// Keep in step with `version:` in pubspec.yaml.
  static const version = '1.0.0';

  static const Flavor flavor = kReleaseMode ? Flavor.prod : Flavor.dev;

  /// Debug tools (fake clock, palette override, unreviewed drafts) exist in
  /// dev builds only. Release builds never show unapproved content.
  static bool get debugTools => flavor == Flavor.dev;
}
