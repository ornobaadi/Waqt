import 'dart:convert';
import 'dart:ui' show Color;

import 'package:home_widget/home_widget.dart';

import '../../core/theme/tokens.dart';
import '../../domain/moments/moment.dart';
import '../../domain/moments/moment_engine.dart';

/// One row of the widget's schedule: what to show from [at] onward.
class WidgetEntry {
  const WidgetEntry({
    required this.at,
    required this.place,
    required this.current,
    required this.next,
    required this.nextAt,
    required this.palette,
  });

  final DateTime at;
  final String place;
  final String current;

  /// "Maghrib 5:17 PM": the countdown is drawn next to it natively.
  final String next;
  final DateTime nextAt;
  final MomentPalette palette;

  Map<String, Object> toJson() {
    int argb(Color c) => c.toARGB32();
    return {
      'at': at.millisecondsSinceEpoch,
      'place': place,
      'current': current,
      'next': next,
      'nextAt': nextAt.millisecondsSinceEpoch,
      'ground': argb(palette.ground),
      'ink': argb(palette.ink),
      'muted': argb(palette.ink.withValues(alpha: 0.68)),
    };
  }
}

/// Pure: prayer days → the widget schedule (one entry per waqt).
List<WidgetEntry> widgetSchedule({
  required List<PrayerDay> days,
  required String place,
  required String Function(MomentId) label,
  required String Function(DateTime) time,
  required MomentPalette Function(MomentId) palette,
}) {
  const engine = MomentEngine(rules: [WaqtRule()]);
  final waqts = [for (final d in days) ...engine.timelineFor(d)];
  return [
    for (final m in waqts)
      WidgetEntry(
        at: m.window.start,
        place: place,
        current: label(m.id),
        // The waqt after sunrise isn't a prayer: point at Dhuhr.
        next: '${label(_next(m.id))} ${time(m.window.end)}',
        nextAt: m.window.end,
        palette: palette(m.id),
      ),
  ];
}

MomentId _next(MomentId w) => switch (w) {
  MomentId.fajr => MomentId.sunrise,
  MomentId.sunrise => MomentId.dhuhr,
  MomentId.dhuhr => MomentId.asr,
  MomentId.asr => MomentId.maghrib,
  MomentId.maghrib => MomentId.isha,
  _ => MomentId.fajr,
};

class WidgetBridge {
  static const provider = 'com.ornobaadi.waqt.WaqtWidgetProvider';

  Future<void> publish(List<WidgetEntry> entries, {required String emptyTitle, required String emptyBody}) async {
    await HomeWidget.saveWidgetData<String>('schedule', jsonEncode([for (final e in entries) e.toJson()]));
    await HomeWidget.saveWidgetData<String>('emptyTitle', emptyTitle);
    await HomeWidget.saveWidgetData<String>('emptyBody', emptyBody);
    await HomeWidget.updateWidget(qualifiedAndroidName: provider);
    final now = DateTime.now();
    final boundaries = [
      for (final e in entries)
        if (e.at.isAfter(now)) e.at,
    ];
    if (boundaries.isNotEmpty) {
      await HomeWidget.scheduleWidgetUpdates(boundaries, qualifiedAndroidName: provider);
    }
  }
}
