import '../moments/moment.dart';
import '../moments/moment_engine.dart';

/// What a user can ask to be reminded of. Calm by default (PRD principle 4):
/// the five prayers on, everything else opt-in.
enum ReminderKind {
  fajr(MomentId.fajr, prayer: true),
  dhuhr(MomentId.dhuhr, prayer: true),
  asr(MomentId.asr, prayer: true),
  maghrib(MomentId.maghrib, prayer: true),
  isha(MomentId.isha, prayer: true),
  lastThird(MomentId.lastThird),
  fridayLastHour(MomentId.fridayLastHour),
  bedtime(MomentId.bedtime);

  const ReminderKind(this.moment, {this.prayer = false});
  final MomentId moment;

  /// Prayer reminders are the only ones that ask for exact timing.
  final bool prayer;

  static const defaults = {fajr, dhuhr, asr, maghrib, isha};
}

class PlannedReminder {
  const PlannedReminder(this.id, this.kind, this.at);
  final int id;
  final ReminderKind kind;
  final DateTime at;

  @override
  String toString() => '#$id ${kind.name} $at';
}

/// Pure: prayer days + preferences → the reminders to schedule.
///
/// Uses a fixed horizon instead of a daily background job: Android keeps
/// scheduled alarms across reboots (the plugin re-arms them), and every app
/// open re-plans, so reminders keep flowing for a week without the app.
class ReminderPlanner {
  const ReminderPlanner({this.engine = const MomentEngine(), this.horizon = const Duration(days: 7)});

  final MomentEngine engine;
  final Duration horizon;

  /// Android caps pending alarms per app at 500; stay far below it.
  static const maxReminders = 120;

  List<PlannedReminder> plan(DateTime now, List<PrayerDay> days, Set<ReminderKind> enabled) {
    if (enabled.isEmpty) return const [];
    final byMoment = {for (final k in enabled) k.moment: k};
    final end = now.add(horizon);
    final out = <PlannedReminder>[];
    final seen = <(ReminderKind, DateTime)>{};
    for (final day in days) {
      for (final m in engine.timelineFor(day)) {
        final kind = byMoment[m.id];
        if (kind == null || m.prayer != null) continue;
        final at = m.window.start;
        if (!at.isAfter(now) || at.isAfter(end)) continue;
        if (seen.add((kind, at))) out.add(PlannedReminder(0, kind, at));
      }
    }
    out.sort((a, b) => a.at.compareTo(b.at));
    return [for (final (i, r) in out.take(maxReminders).indexed) PlannedReminder(i + 1, r.kind, r.at)];
  }
}
