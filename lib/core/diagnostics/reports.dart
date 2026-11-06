import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/content/content_repository.dart';
import '../config/flavor.dart';

/// Privacy-respecting diagnostics: errors stay in a small on-device log. A
/// report is only ever a pre-filled form the user reads and sends themselves.
/// No analytics, no crash SDK, no location or personal data in any report.
abstract final class Reports {
  static const repo = 'https://github.com/ornobaadi/Waqt';
  static const _key = 'crashlog.v1';
  static const _max = 15;
  static SharedPreferences? _prefs;

  static void install(SharedPreferences prefs) {
    _prefs = prefs;
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      record(details.exceptionAsString(), details.stack);
      previous?.call(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      record('$error', stack);
      return false; // keep default handling
    };
  }

  static void record(String error, StackTrace? stack) {
    final p = _prefs;
    if (p == null) return;
    // First frames only: enough to locate the bug, short enough to read.
    final frames = (stack?.toString() ?? '').split('\n').take(6).join('\n');
    final entry = '${DateTime.now().toUtc().toIso8601String()} $error\n$frames';
    final log = [...?p.getStringList(_key), entry];
    unawaited(p.setStringList(_key, log.length > _max ? log.sublist(log.length - _max) : log));
  }

  static List<String> get log => _prefs?.getStringList(_key) ?? const [];

  static Uri issueUri(String title, String body) =>
      Uri.parse('$repo/issues/new').replace(queryParameters: {'title': title, 'body': body});

  static Uri contentIssue(ContentItem i) => issueUri(
    'Content: ${i.id}',
    [
      '**Item:** `${i.id}` (v${i.version}, ${i.status.name})',
      '**Reference:** ${i.source.collection} ${i.source.number}',
      '**Source link:** ${i.source.url}',
      '',
      '**What is wrong?** (wording, translation, reference, grading)',
      '',
      '',
      '_App ${AppConfig.version} (${AppConfig.flavor.name})_',
    ].join('\n'),
  );

  static Future<void> reportContent(ContentItem i) => launchUrl(contentIssue(i), mode: LaunchMode.externalApplication);

  static Future<void> reportProblem() {
    final errors = log.reversed.take(3).join('\n\n');
    return launchUrl(
      issueUri(
        'Problem report',
        [
          '**What happened?**',
          '',
          '',
          '**Steps to reproduce**',
          '',
          '',
          '---',
          'App ${AppConfig.version} (${AppConfig.flavor.name}), ${defaultTargetPlatform.name}',
          if (errors.isNotEmpty) ...['', 'Recent errors on this device:', '```', errors, '```'],
        ].join('\n'),
      ),
      mode: LaunchMode.externalApplication,
    );
  }
}
